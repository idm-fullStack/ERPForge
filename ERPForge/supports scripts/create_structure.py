"""
Скрипт для автоматического создания структуры папок из файла с древовидной структурой
Использование: python create_structure.py
"""

import os
import re
from pathlib import Path

FILE_EXTENSIONS = {'.yaml', '.yml', '.md', '.txt', '.json', '.tsp', '.dsl', '.py', '.js', '.ts', '.css', '.html', '.xml', '.toml', '.tf'}

def is_file(name):
    return any(name.endswith(ext) for ext in FILE_EXTENSIONS)

def parse_structure_file(file_path):
    paths = []
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    if not lines:
        return paths
    
    base_dir = lines[0].strip().rstrip('/').strip()
    
    path_stack = []
    
    for line in lines[1:]:
        if not line.strip():
            continue
        
        indent_match = re.match(r'^([\s│├└]*)', line)
        if not indent_match:
            continue
        
        indent_str = indent_match.group(1)
        
        depth = 0
        i = 0
        while i < len(indent_str):
            if indent_str[i] == '│' or indent_str[i] == '├' or indent_str[i] == '└':
                depth += 1
                i += 1
            elif indent_str[i] == ' ':
                space_count = 0
                while i < len(indent_str) and indent_str[i] == ' ':
                    space_count += 1
                    i += 1
                depth += space_count // 4
            else:
                i += 1
        
        name_match = re.search(r'[─]+\s+([^/\n]+)', line)
        if not name_match:
            name_match = re.search(r'([^/\n]+)$', line.strip())
            if not name_match:
                continue
        
        name = name_match.group(1).strip()
        
        if is_file(name):
            continue
        
        
        while len(path_stack) > depth:
            path_stack.pop()
        
        path_stack.append(name)
        
        full_path = os.path.join(base_dir, *path_stack)
        paths.append(full_path)
    
    return paths

def create_directories(paths, base_dir='.'):
    """
    Создает папки для всех путей
    """
    created = []
    for path in paths:
        full_path = os.path.join(base_dir, path)
        try:
            os.makedirs(full_path, exist_ok=True)
            created.append(full_path)
            print(f"Создано: {full_path}")
        except Exception as e:
            print(f" Ошибка при создании {full_path}: {e}")
    
    return created

def main():
    # Файл со структурой
    structure_file = 'analytics_structure.txt'
    
    if not os.path.exists(structure_file):
        print(f" Файл {structure_file} не найден!")
        return
    
    print(f" Читаем структуру из {structure_file}...")
    paths = parse_structure_file(structure_file)
    
    print(f" Найдено {len(paths)} папок")
    print(" Создаем структуру папок...")
    
    create_directories(paths)
    
    print("\n Готово!")

if __name__ == '__main__':
    main()