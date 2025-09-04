@echo off
echo Membuat virtual environment di src\scripts\venv ...
python -m venv src\scripts\venv

echo.
echo Mengaktifkan virtual environment...
call src\scripts\venv\Scripts\activate

echo.
echo Menginstall dependencies...
pip install --upgrade pip
pip install easyocr opencv-python-headless pillow rapidfuzz

echo.
echo Selesai. Virtual environment aktif.


