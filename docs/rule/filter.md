# Filter

`Filter` Used to filter the requests that need to be processed and return

## candidate

`Filter` Currently includes the following types：

- All
- Domain(String)
- DomainKeyword(String)
- DomainPrefix(String)
- DomainSuffix(String)
- UrlRegex(fancy_regex::Regex)

> **Note**  
> In the current version, `domain` related types match `host`, which usually does not affect the result 
> When a website uses an unconventional port, the rule needs to indicate the port  
> This behavior will be optimized in future versions  

### All 

When the filter is specified as `all`, all requests and returns will be hit, usually used to perform logging behavior

```yaml
- name: "log"
  filter: all
  action:
    - log-req
    - log-res
```

### Domain

`domain` Full match on the domain name

```yaml
- name: "redirect"
  filter:
    domain: 'none.zu1k.com'
  action:
    redirect: "https://zu1k.com/"
```

### DomainKeyword 

`domain-keyword`Keyword matching for domain names

```yaml
- name: "reject CSDN"
  filter:
    domain-keyword: 'csdn'
  action: reject
```

### DomainPrefix

`domain-prefix` Prefix matching on domain names

```yaml
- name: "ad prefix"
  filter:
    domain-prefix: 'ads' // example: "ads.xxxxx.com"
  action: reject
```

### DomainSuffix

`domain-suffix` Suffix matching on domain names


```yaml
- name: "redirect"
  filter:
    domain-suffix: 'google.com.cn'
  action:
    redirect: "https://google.com"
```

### UrlRegex 

`url-regex`Regular matching on the entire url

```yaml
- name: "youtube track"
  mitm: "*.youtube.com"
  filter:
    url-regex: '^https?:\/\/(www|s)\.youtube\.com\/(pagead|ptracking)'
  action: reject
```

## Multiple Filters

`filters` field supports a single filter and multiple filters, and the relationship between multiple filters is `or`

```yaml
- name: "youtube-2"
  mitm:
    - "*.youtube.com"
    - "*.googlevideo.com"
  filters:
    - url-regex: '^https?:\/\/[\w-]+\.googlevideo\.com\/(?!(dclk_video_ads|videoplayback\?)).+(&oad|ctier)'
    - url-regex: '^https?:\/\/(www|s)\.youtube\.com\/api\/stats\/ads'
    - url-regex: '^https?:\/\/(www|s)\.youtube\.com\/(pagead|ptracking)'
    - url-regex: '^https?:\/\/\s.youtube.com/api/stats/qoe?.*adformat='
  action: reject
```

Multiple rules with the same action can be aggregated into a single rule for easy maintenance
