<div align="center">
  <img src="icon.png" alt="Logo" width="128" height="128">
<h1 align="center">verse</h1>
<p>Frontend GUI for LLMs</p>
</div>

<br>

## Features
- No limitations in ML framswork / platform
- Markdown & LaTeX rendering support
- Simple adaptation

## Get Started
The only thing you needs to do is to prepare a python script
```python
# Get your model ready
While True:
    x = input()   # VERSE will sent your prompt as input
    # Your inference code
    print(response)
    # VERSE will record any printed content as latest response and previous
    # responses will be overwritten, so remember to print complete sentences.
    print('\\end')  # VERSE will know the response is finished
```
