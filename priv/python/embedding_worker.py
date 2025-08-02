from sentence_transformers import SentenceTransformer
import torch

# Load model once per process
model = SentenceTransformer(
    "Qwen/Qwen3-Embedding-0.6B",
    model_kwargs={"attn_implementation": "flash_attention_2", "device_map": "auto"},
    tokenizer_kwargs={"padding_side": "left"},
)

def run_embeddings(queries, documents):
    query_embeddings = model.encode(queries, prompt_name="query")
    doc_embeddings = model.encode(documents)
    similarity = model.similarity(query_embeddings, doc_embeddings)
    # Convert tensor to list of lists so it's serializable
    return similarity.tolist()
