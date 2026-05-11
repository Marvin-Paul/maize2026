import os
import re

def safe_replace_v2(content):
    # Gemini model fix
    content = content.replace("model: 'gemini-1.5-flash-latest'", "model: 'gemini-1.5-flash'")
    
    # Image fix
    content = content.replace(
        "https://images.unsplash.com/photo-1551327151-6435c2494191?auto=format&fit=crop&q=80",
        "https://picsum.photos/seed/maize/400/200"
    )

    # Backgrounds
    content = content.replace('Color(0xFF0A0E12)', 'Color(0xFFF5F7FA)')
    content = content.replace('Color(0xFF151B23)', 'Color(0xFFFFFFFF)')
    content = content.replace('Color(0xFF1B2D1B)', 'Color(0xFFE8F5E9)')
    content = content.replace('Brightness.dark', 'Brightness.light')
    content = content.replace('ThemeData.dark()', 'ThemeData.light()')
    
    # Swap opacities
    content = content.replace('Colors.white.withValues', 'TEMP_W_V')
    content = content.replace('Colors.black.withValues', 'TEMP_B_V')
    content = content.replace('TEMP_W_V', 'Colors.black.withValues')
    content = content.replace('TEMP_B_V', 'Colors.white.withValues')
    
    # Text colors
    content = content.replace('Colors.white70', 'TEMP_W70')
    content = content.replace('Colors.white54', 'TEMP_W54')
    content = content.replace('Colors.white30', 'TEMP_W30')
    content = content.replace('Colors.white24', 'TEMP_W24')
    content = content.replace('Colors.black26', 'TEMP_B26')
    
    content = content.replace('TEMP_W70', 'Colors.black87')
    content = content.replace('TEMP_W54', 'Colors.black54')
    content = content.replace('TEMP_W30', 'Colors.black38')
    content = content.replace('TEMP_W24', 'Colors.black12')
    content = content.replace('TEMP_B26', 'Colors.grey.shade200')
    
    # Swap plain white and black
    content = re.sub(r'Colors\.white(?!\w)', 'TEMP_WHITE', content)
    content = re.sub(r'Colors\.black(?!\w)', 'TEMP_BLACK', content)
    
    content = content.replace('TEMP_WHITE', 'Colors.black')
    content = content.replace('TEMP_BLACK', 'Colors.white')
    
    return content

def main():
    base_dir = r"D:\maize2026\maizeguard_flutter\lib"
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = safe_replace_v2(content)
                
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
    print("Done")

if __name__ == "__main__":
    main()
