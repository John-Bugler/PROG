from pdf2docx import Converter

def pdf_to_docx(pdf_file, docx_file):
    # Inicializace konvertoru
    cv = Converter(pdf_file)
    
    # Konverze PDF do DOCX
    cv.convert(docx_file, start=0, end=None)
    
    # Uzavření konvertoru
    cv.close()

# Nastavte cesty k PDF a výstupnímu DOCX souboru
pdf_file = "cesta_k_souboru.pdf"
docx_file = "vystupni_soubor.docx"

# Zavolejte funkci pro převod
pdf_to_docx(pdf_file, docx_file)
