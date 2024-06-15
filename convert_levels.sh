for file in Source/levels/*.tmj; do
    python3 convert_level.py "$file" > "${file%.tmj}.json"
done
