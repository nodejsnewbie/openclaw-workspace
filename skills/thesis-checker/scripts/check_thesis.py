#!/usr/bin/env python3
"""
毕业论文自动检查脚本
支持docx、pdf、md格式论文的格式和内容检查
"""

import os
import sys
import argparse
from pathlib import Path
from docx import Document
import PyPDF2
import markdown

def load_school_requirements():
    """加载学校格式要求"""
    req_files = [
        Path(__file__).parent.parent / "references/school-format-requirements.md",
        Path(__file__).parent.parent / "references/major-thesis-requirements.md"
    ]
    
    requirements = []
    for req_file in req_files:
        if req_file.exists():
            with open(req_file, 'r', encoding='utf-8') as f:
                requirements.append(f.read())
        else:
            print(f"⚠️  警告：未找到要求文件 {req_file}")
    
    return "\n".join(requirements)

def read_docx(file_path):
    """读取docx文件内容，保留段落和格式信息"""
    doc = Document(file_path)
    content = []
    for i, para in enumerate(doc.paragraphs):
        content.append({
            'line': i + 1,
            'text': para.text,
            'style': para.style.name,
            'alignment': para.alignment,
            'indent': para.paragraph_format.first_line_indent,
            'line_spacing': para.paragraph_format.line_spacing
        })
    return content

def read_pdf(file_path):
    """读取pdf文件内容"""
    content = []
    with open(file_path, 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        for page_num, page in enumerate(reader.pages):
            text = page.extract_text()
            content.append({
                'page': page_num + 1,
                'text': text
            })
    return content

def read_md(file_path):
    """读取markdown文件内容"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    return markdown.markdown(content)

def check_format(content, requirements):
    """检查格式合规性"""
    issues = []
    
    # 示例检查规则，实际使用时根据学校要求扩展
    for para in content:
        if isinstance(para, dict) and 'style' in para:
            # 检查标题格式
            if para['style'].startswith('Heading 1'):
                if not para['text'].strip():
                    issues.append({
                        'position': f"第{para['line']}行",
                        'type': '格式问题',
                        'description': '一级标题为空',
                        'suggestion': '请补充一级标题内容'
                    })
            # 检查段落缩进
            if para['style'] == 'Normal' and para['text'].strip():
                if not para['indent'] or para['indent'] < 28:  # 28磅约等于2字符
                    issues.append({
                        'position': f"第{para['line']}行",
                        'type': '格式问题',
                        'description': '正文段落未设置首行缩进2字符',
                        'suggestion': '请设置段落首行缩进为2字符'
                    })
    
    return issues

def generate_report(issues, output_path=None):
    """生成检查报告"""
    report = ["# 毕业论文检查报告\n"]
    
    if not issues:
        report.append("✅ 未检测到格式问题，论文格式符合要求！")
    else:
        report.append(f"📊 共检测到 {len(issues)} 个问题：\n")
        
        # 按类型分类
        issue_types = {}
        for issue in issues:
            issue_type = issue['type']
            if issue_type not in issue_types:
                issue_types[issue_type] = []
            issue_types[issue_type].append(issue)
        
        for issue_type, type_issues in issue_types.items():
            report.append(f"## {issue_type} ({len(type_issues)}个)\n")
            for i, issue in enumerate(type_issues, 1):
                report.append(f"### {i}. {issue['position']}")
                report.append(f"**问题描述**：{issue['description']}")
                report.append(f"**修改建议**：{issue['suggestion']}\n")
    
    report_content = "\n".join(report)
    
    if output_path:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(report_content)
        print(f"✅ 检查报告已生成：{output_path}")
    
    return report_content

def main():
    parser = argparse.ArgumentParser(description='毕业论文格式检查工具')
    parser.add_argument('file', help='论文文件路径（支持docx、pdf、md格式）')
    parser.add_argument('--output', '-o', help='检查报告输出路径')
    args = parser.parse_args()
    
    file_path = Path(args.file)
    if not file_path.exists():
        print(f"❌ 错误：文件不存在 {file_path}")
        sys.exit(1)
    
    # 加载学校要求
    requirements = load_school_requirements()
    if not requirements:
        print("⚠️  未加载到学校格式要求，将使用默认检查规则")
    
    # 读取文件内容
    print(f"📄 正在读取论文文件：{file_path}")
    content = []
    if file_path.suffix.lower() == '.docx':
        content = read_docx(file_path)
    elif file_path.suffix.lower() == '.pdf':
        content = read_pdf(file_path)
    elif file_path.suffix.lower() == '.md':
        content = read_md(file_path)
    else:
        print(f"❌ 不支持的文件格式：{file_path.suffix}")
        sys.exit(1)
    
    # 执行检查
    print("🔍 正在执行格式检查...")
    issues = check_format(content, requirements)
    
    # 生成报告
    output_path = args.output or f"{file_path.stem}_检查报告.md"
    report = generate_report(issues, output_path)
    
    print("\n" + "="*50)
    print(report)

if __name__ == "__main__":
    main()
