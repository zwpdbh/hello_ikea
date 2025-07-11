# How to Fork and Modify Dependencies

Currently, in the `mix.exs` it contains `{:instructor_lite, "~> 1.0.0"}`.
However, I need to debug it and probably add changes to it so it could be customized to fit a special LLM endpoint. 


## Steps 
First, fork that project. Then git clone your project into local folder.

Second, update the dependencies and `mix deps.get`.
```sh 
{:instructor_lite, path: "~/code/elixir_programming/examples/instructor_lite"},

mix deps.get
```

Last, click one of the function in your code, like `InstructorLite.instruct`, it should direct you into 
code but inside your cloned `instructor_lite` folder locally.