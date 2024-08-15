```{r}
#| echo: false
current_file_path <- knitr::current_input(dir = TRUE)
Sys.setenv(CURRENT_FILE_PATH = current_file_path)

```

```{python}
#| echo: false
import os

current_file_path = os.environ.get('CURRENT_FILE_PATH')
print("Current file path:", current_file_path)

with open(current_file_path, 'r') as file:
    content = file.read()
print(len(content))

```

Here is some more text

and now