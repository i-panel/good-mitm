# Rule

`Rule` used to manipulate Video-MITM

一A qualifying rule needs to contain the following:

- `name`：used to distinguish between different rules，convenience and maintenance
- [`filter`](rule/filter.md)：Used to filter out the content that needs to be processed from many `request` and `return`
- [`action`](rule/action.md)：to perform the desired behavior，include `redirect`、`block`、`modify` Wait
- Specify domains that require MITM if necessary

```yaml
- name: "Block Youtube Tracking"
  mitm: "*.youtube.com"
  filter:
    url-regex: '^https?:\/\/(www|s)\.youtube\.com\/(pagead|ptracking)'
  action: reject
```

At the same time, a qualified rule needs to meet the following requirements:

- Focus: One rule is only used to do one thing
- Simple: use simple method to handle, convenient and maintain
- Efficient: Try to use efficient methods, such as using domain name suffixes and domain name prefixes to replace domain name regular expressions
