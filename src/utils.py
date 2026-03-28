import re

def execute_sql_file(filepath: str, ch):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Eliminar comentarios de línea (--)
    content = re.sub(r'--[^\n]*', '', content)
    
    # 2. Eliminar comentarios de bloque (/* */)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)

    # 3. Split por ; y limpiar
    statements = [
        s.strip()
        for s in content.split(';')
        if s.strip()  # ignorar vacíos
    ]

    total = len(statements)
    print(f"Sentencias encontradas: {total}")

    for i, stmt in enumerate(statements, 1):
        try:
            ch.execute(stmt)
            preview = ' '.join(stmt.split())[:60]
            print(f"[{i}/{total}] ✓ {preview}...")
        except Exception as e:
            print(f"[{i}/{total}] ✗ Error: {e}")
            print(f"  Statement completo:\n{stmt}")
            raise

    print(f"\n✓ {total} sentencias ejecutadas desde {filepath}")