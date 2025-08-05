# from transformers.utils import TRANSFORMERS_CACHE
# print(f"Default Hugging Face cache: {TRANSFORMERS_CACHE}")

from sentence_transformers import SentenceTransformer

def run_demo():
    model = SentenceTransformer("Qwen/Qwen3-Embedding-0.6B")
    queries = ["What is the capital of China?"]
    docs = ["The capital of China is Beijing."]
    query_emb = model.encode(queries, prompt_name="query")
    doc_emb = model.encode(docs)
    sim = model.similarity(query_emb, doc_emb)
    print("Similarity matrix:", sim.tolist())  # tolist() for JSON/Elixir friendliness

if __name__ == "__main__":
    run_demo()