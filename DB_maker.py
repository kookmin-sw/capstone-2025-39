import os
from datetime import datetime
from langchain_community.document_loaders import (
    DirectoryLoader,
    CSVLoader,
    UnstructuredExcelLoader
)
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS

def load_documents():
    documents = []
    
    # Load text files
    txt_loader = DirectoryLoader('dataset', glob="**/*.txt")
    documents.extend(txt_loader.load())
    
    # Load CSV files
    csv_loader = DirectoryLoader('dataset', glob="**/*.csv", loader_cls=CSVLoader)
    documents.extend(csv_loader.load())
    
    # Load Excel files
    excel_loader = DirectoryLoader('dataset', glob="**/*.xlsx", loader_cls=UnstructuredExcelLoader)
    documents.extend(excel_loader.load())
    
    return documents

def create_vector_db():
    # Load documents from the dataset directory
    documents = load_documents()
    
    # Split documents into chunks
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200,
        length_function=len,
    )
    splits = text_splitter.split_documents(documents)
    
    # Initialize embeddings
    embeddings = HuggingFaceEmbeddings(
        model_name="sentence-transformers/all-MiniLM-L6-v2"
    )
    
    # Create FAISS vector store
    vectorstore = FAISS.from_documents(splits, embeddings)
    
    # Create timestamp for the save directory
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    save_dir = f"vectorDB/faiss_index_{timestamp}"
    
    # Save the vector store
    vectorstore.save_local(save_dir)
    print(f"Vector database saved to: {save_dir}")

if __name__ == "__main__":
    create_vector_db()
