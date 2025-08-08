# Part04: Generate Conversation Title 

## Problem

Currently, when user send a message, it creates a corresponding conversation. 
But that conversation is missing title.

## Features 

- In sidebar, sort conversation by its last updated message. So, the conversation contains the latest message updated shows at the top. 
- If a conversation has no title generate its title by 
  - There are more than 3 messages.
  - Or, the conversation is created 10 mins from now. 
- In addition, add a `delete` button to conversation item to let user remove it from his conversation histories.
- Currently, one user has many conversations and one conversation `belongs_to` one user. 
  - To support multiple person's conversation, we need to change this such that one conversation has many users.


## Step01

- Modify UI to support delete conversation.