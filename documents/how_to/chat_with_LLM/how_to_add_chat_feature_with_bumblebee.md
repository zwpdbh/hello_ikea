# How to add chat feature with bumblebee 

## Current status summary 

- Embedding and save document under a folder into `pgvector`.
- Given a query, find relative embedding document chunks and use it as context to build prompt.
- Use the prompt to generate response 

## Feature to implement 

- Chat with persistence. Save chat into DB.
- Support `streaming` resonse from `Bumblebee`.


## Step01 -- build chat model 

To save chat persistently into db, we need to build related model.
I will use Ash.Resource to model this. 

## Step02 -- build chat UI using liveview 

## Step03 -- Improve Chat experience by streaming