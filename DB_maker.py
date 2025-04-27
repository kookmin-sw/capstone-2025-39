import os
from datetime import datetime
from langchain_community.document_loaders import (
    DirectoryLoader,
    CSVLoader
)
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from dotenv import load_dotenv
from langchain_openai import OpenAIEmbeddings

def load_documents_from_dir():
    documents = []
    # Load CSV files with UTF-8 encoding
    csv_loader = DirectoryLoader(
        'dataset', 
        glob="**/*.csv", 
        loader_cls=CSVLoader,
        loader_kwargs={'encoding': 'utf-8'}
    )
    documents.extend(csv_loader.load())
    
    return documents

def create_vector_db():
    # Load documents from the dataset directory
    documents = load_documents_from_dir()
    
    # Split documents into chunks
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200,
        length_function=len,
    )
    splits = text_splitter.split_documents(documents)
    
    # Initialize embeddings
    embed_model = OpenAIEmbeddings(
        model="text-embedding-3-small"
    )
    # Create FAISS vector store
    vectorstore = FAISS.from_documents(splits, embed_model)
    
    # Create timestamp for the save directory
    timestamp = datetime.now().strftime("%Y%m%d")
    save_dir = f"vectorDB/{timestamp}FAISS"
    
    # Save the vector store
    vectorstore.save_local(save_dir)
    print(f"Vector database saved to: {save_dir}")

if __name__ == "__main__":
    load_dotenv() # Load environment variables from .env file
    create_vector_db()
