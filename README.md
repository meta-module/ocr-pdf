# ocr-pdf
ocr-pdf.metamodules.org



## Install

```bash
curl http://download.metamodule.org
chmod +x mm.sh
mm.sh install
```


## Start Use metamodules

Create **mm.json** file
```bash
mm init
```

### INIT

Create empty validator section
```bash
mm validator create
```

Create empty generator section
```bash
mm generator create
```


### Add to list current list

Download schema and valid all listed sections in a document
```bash
mm validator create "lifecycle" "http://lifecycle.dsdasdadas.org"
```

Download library list and put objects to root **mm.json**
```bash
mm generator create "lifecycle" "http://lifecycle.dsdasdadas.org"
```


### UPDATE ALL

Update validator section based on list
```bash
mm validator update
```

Update generator section based on list
```bash
mm generator update
```

### UPDATE SELECTED

Update validator section based on list
```bash
mm validator update "lifecycle" "http://lifecycle.dsdasdadas.org" "lifecycle2" "http://lifecycle.dsdasdadas.org"
```

Update generator section based on list
```bash
mm generator update "lifecycle" "http://lifecycle.dsdasdadas.org" "lifecycle2" "http://lifecycle.dsdasdadas.org"
```



### Show List current list

Download schema and valid all listed sections in a document 
```bash
mm list validator
```

Download library list and put objects to root **mm.json**
```bash
mm list generator 
```



### Show List current list

Download schema and valid all listed sections in a document
```bash
mm validator
```

Download library list and put objects to root **mm.json**
```bash
mm generator
```


Create section based on default
```bash
mm list schema
```

mm remove schema **[part of schema url]**
```bash
mm remove schema *generator*
```



## JSON examples

Create empty validator
```bash
mm create validator 
```
```json
{
  
} 
```

Create validator, add to validator section, create section if not exist
```bash
mm create validator "definition" "http://lifecycle.dsdasdadas.org" 
```
```json
{
  
} 
```

OR

Create empty section without validation
```bash
mm create definition 
```

```json
{
  
} 
```

OR 

Create with defaults from generator and add to generator section
```bash
mm create generator "definition" "http://lifecycle.dsdasdadas.org" 
```

```json
{
  
} 
```