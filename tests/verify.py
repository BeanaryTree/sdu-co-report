"""Compile fixtures, check PDF geometry/content, and render every page for review.

Requires: pip install typst==0.15.0 pymupdf
Run from any directory: python tests/verify.py
"""
from pathlib import Path
import re
import tempfile
import shutil
import tomllib

ROOT = Path(__file__).resolve().parents[1]
import typst
import pymupdf

OUT = ROOT / '.qa'
OUT.mkdir(exist_ok=True)
docs = {}
for source in ['examples/example.typ', 'tests/empty.typ',
               'tests/stress.typ', 'tests/boundaries.typ', 'tests/three-line-table.typ']:
    name = Path(source).stem
    data, warnings = typst.compile_with_warnings(str(ROOT / source), root=str(ROOT))
    assert not warnings, (source, warnings)
    (OUT / f'{name}.pdf').write_bytes(data)
    doc = pymupdf.open(stream=data)
    docs[name] = doc
    for i, page in enumerate(doc):
        assert abs(page.rect.width - 595.276) < 1
        assert abs(page.rect.height - 841.89) < 1
        assert '\ufffd' not in page.get_text(), (name, i, 'missing character')
        # Verify all text stays inside the page's 20 mm margins (1 pt tolerance).
        for word in page.get_text('words'):
            x0, y0, x1, y1 = word[:4]
            assert x0 >= 55.5 and x1 <= 539.8, (name, i, word)
            assert y0 >= 55.5 and y1 <= 786.3, (name, i, word)
        page.get_pixmap(matrix=pymupdf.Matrix(1.25, 1.25)).save(
            OUT / f'{name}-{i + 1}.png')
    print(f'PASS {source}: {len(doc)} pages, no warnings, text inside margins')

assert len(docs['example']) == len(docs['empty']) == 1
stress = re.sub(r'\s+', '', ''.join(page.get_text() for page in docs['stress']))
assert stress.count('这是一个不分段的长段落') == 60
assert stress.count('数据记录：验证跨页表格中的边框与重复表头。') == 45
assert '全文结束标记。' in stress
assert len(docs['stress']) >= 3
pages = [p.get_text() for p in docs['boundaries']]
head = next(i for i, t in enumerate(pages) if '不得落单的标题' in t)
assert head > 0, 'Fixture no longer reaches page boundary'
assert '标题后的第一段应与标题出现在同一页。' in pages[head]
picture = next(i for i, t in enumerate(pages) if '超高图片：' in t)
assert '超高图片后的内容应完整保留。' in pages[picture]
assert '最终边界标记。' in ''.join(pages)
assert all(t.strip() for t in pages), 'Unexpected empty page'
print('PASS pagination, retained content, heading keep, and oversized image checks')

# Simulate manually copying a package, then compile outside its source root.
with tempfile.TemporaryDirectory(prefix='sdu-report-test-') as directory:
    workspace = Path(directory)
    packages = workspace / 'packages'
    manifest = tomllib.loads((ROOT / 'typst.toml').read_text(encoding='utf-8'))
    package = manifest['package']
    installed = packages / 'local' / package['name'] / package['version']
    shutil.copytree(ROOT, installed,
        ignore=shutil.ignore_patterns('.git', '.qa', '.venv', '.tools', '__pycache__'))
    assert manifest['package']['license'] == 'MIT'
    project = workspace / 'new-report'
    shutil.copytree(installed / 'template', project)
    data, warnings = typst.compile_with_warnings(str(project / 'main.typ'),
        root=str(project), package_path=str(packages))
    assert not warnings, warnings
    assert len(pymupdf.open(stream=data)) == 1
    # Direct import needs only report.typ, with no package manifest or package path.
    direct = workspace / 'direct-report'
    direct.mkdir()
    shutil.copy2(ROOT / 'report.typ', direct / 'report.typ')
    source = (project / 'main.typ').read_text(encoding='utf-8-sig')
    source = source.replace(f'@local/{package["name"]}:{package["version"]}', 'report.typ')
    (direct / 'main.typ').write_text(source, encoding='utf-8')
    data, warnings = typst.compile_with_warnings(str(direct / 'main.typ'), root=str(direct))
    assert not warnings, warnings
    assert len(pymupdf.open(stream=data)) == 1
print('PASS manually copied local package, template, and standalone file import')

for page in docs['three-line-table']:
    assert '测量值' in page.get_text() and '序号' in page.get_text()
text = ''.join(page.get_text() for page in docs['three-line-table'])
assert all(value in text for value in ['-2', '3.5', '2026-09-24', '198'])
print('PASS numeric multipage three-line table')

source = '''#import "report.typ": *
#show: experiment-report.with()
#section("A")[
= Alpha
= Beta
]
#section("B")[
= Gamma
#lorem(1000)
= Delta
]
'''
data, warnings = typst.compile_with_warnings(source.encode(), root=str(ROOT))
assert not warnings, warnings
pages = pymupdf.open(stream=data)
text = re.sub(r'\s+', '', ''.join(p.get_text() for p in pages))
assert all(s in text for s in ['1.Alpha', '2.Beta', '1.Gamma', '2.Delta'])
print('PASS heading numbering reset per section')
