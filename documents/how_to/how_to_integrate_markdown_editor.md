# How to integrate markdown editor to liveview

## Description

Currently, the post's content is a textarea. How to enhance it with a rich text editor? 
Say, we want to user use markdown editor to write the post. 

And later, when view the post, the content is rendered as markdown file. 
To do so, we need following packages:

- [EasyMDE - Markdown Editor](https://github.com/Ionaru/easy-markdown-editor)
- [Marked](https://github.com/markedjs/marked?tab=readme-ov-file)

## Steps 

1. Install npm packages in to assets 

```sh 
# in js/easymde_hook.js
cd assets && npm init -y
npm install easymde marked
```

2. Create `easymde_hook.js` 

```js
import EasyMDE from "easymde";
import { marked } from "marked";

// Add sanitization if needed
marked.setOptions({
  sanitize: true // Enable basic XSS protection
});


export const MarkdownRenderHook = {
  mounted() {
    const content = this.el.dataset.markdownContent;
    this.el.innerHTML = marked.parse(content);
  }
};

export const MarkdownEditorHook = {
  mounted() {
    this.editor = new EasyMDE({
      element: this.el.querySelector("#markdown-editor"),
      autoDownloadFontAwesome: false,
      spellChecker: false,
      previewRender: (text) => marked.parse(text),
    });

    // Auto-save: for send markdown editor's content to liveview
    let lastSavedContent = this.editor.value();
    const autoSaveInterval = setInterval(() => {
      const currentContent = this.editor.value();
      if (currentContent !== lastSavedContent) {
        this.pushEvent("auto-save", { content: currentContent });
        lastSavedContent = currentContent;
      }
    }, 5000); // 5000ms = 5 seconds

    // Cleanup interval on destroy
    this.onDestroy = () => clearInterval(autoSaveInterval);

    // Explicitly:
    // 1. Coordinates with the CSS fullscreen styling
    // 2. Prevents potential LiveView DOM reconciliation issues
    // 3. Future-proofs against LiveView template changes
    // 4. Maintains proper z-index layering with your app's layout
    this.editor.codemirror.on("fullscreenChange", (_cm, isFullscreen) => {
      if (isFullscreen) {
        this.el.classList.add("fullscreen");
        this.el.setAttribute("phx-update", "ignore");
      } else {
        this.el.classList.remove("fullscreen");
        this.el.setAttribute("phx-update", "morph");
      }
    });


    this.editor.codemirror.on("change", () => {
      this.pushEvent("markdown-update", { content: this.editor.value() });
    });
  },
  updated() {
    if (this.editor && this.el.querySelector("#markdown-editor").value !== this.editor.value()) {
      this.editor.value(this.el.querySelector("#markdown-editor").value);
    }
  }
};
```

3. Integrate `easymde_hook.js` into `app.js` 

```js 
// in app.js 
import { MarkdownEditorHook, MarkdownRenderHook } from "./easymde_hooks"

// Add to hooks configuration
let Hooks = {};
Hooks.MarkdownEditor = MarkdownEditorHook;
Hooks.MarkdownRender = MarkdownRenderHook;

// use the Hooks 
const liveSocket = new LiveSocket("/live", Socket, {
  ...
  hooks: Hooks,
});

// Add markdown rendering after initial page load
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.markdown-content').forEach(element => {
    const mdContent = element.dataset.markdown;
    element.innerHTML = marked.parse(mdContent);
  });
});
```

4. Import dependent css 

Edit `app.css` 

```css 
/* (optional) Explicitly load font-awesome if it is not present */
@import "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css";

/* This file is for your main application CSS */
/* Import EasyMDE styles */
@import "easymde/dist/easymde.min.css";

/* Custom EasyMDE editor styling */
.EasyMDEContainer .CodeMirror {
  border: 1px solid #e5e7eb;
  border-radius: 0.375rem;
}
```

5. Render markdown in `Post.ShowLive`  

Set `phx-hook="MarkdownRender"` in `div`. The `MarkdownRender` is from `Hooks.MarkdownRender = MarkdownRenderHook;`

```elixir 
<div
  id="render-post"
  class="prose max-w-none markdown-content"
  phx-hook="MarkdownRender"
  data-markdown-content={@post.content}
>
  {@post.content}
</div>
```

1. Support markdown edit in `Post.FormLive` 

We need to modify ` <.input field={form[:content]} type="textarea" label="Content" />` 

```elixir
<div
 phx-update="ignore"
 id="markdown-editor-container"
 phx-hook="MarkdownEditor"
 class="relative"
>
 <.input
   field={form[:content]}
   type="textarea"
   label="Content"
   id="markdown-editor"
   class="hidden"
 />
</div>
```

1. It is better to auto save posts 

```elixir 
# In Post.FormLive
@impl true
def handle_event("auto-save", %{"content" => content}, socket) do
 form_data = %{"content" => content}

 case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
   {:ok, _post} ->
     {:noreply, socket}

   {:error, form} ->
     Logger.info("Error auto-saving: #{inspect(form)}")
     {:noreply, assign(socket, :form, form)}
 end
end
```
