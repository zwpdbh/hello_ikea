# Part02: Chat in LiveView 

## Current Status 

- Chat liveview page is protected by login.
- Each message is rendered (fake message).
- User could enter message trigger "submit". Handle by event `submit` with who and content. 

## UI parts 

- Need to track if a new chat is created (new conversation)

## Notes 

- When user submit message: 
  - Track if it in a new conversation. 
    - If not, create one. 
    - If it is in a conversatio, then create message associate to a conversation.
  - This means, when user submit a message, the url has to be redicted to new url to reflect with the 
    new created conversation.


## Next to do

- `New Conversation` button, when clicked, should direct user to "/chat".
- When user submit first message, it direct user to a conversation and continue 
  with the conversation in "/chat/xxxxx"