# modifier

Modifiers are used to perform modification operations，Includes modification requests and modification returns

## candidate

Depending on the location of the content that needs to be modified, the modifiers are divided into the following categories：

- Header(MapModify)
- Cookie(MapModify)
- Body(TextModify)

### TextModify text modifier

`TextModify` Mainly modify the text, and currently support two methods：

- Set text content directly
- Ordinary replacement or regex replacement

#### set directly

For plain type direct settings, the content will be directly reset to the specified text

```yaml
- name: "modify response body plain"
  filter:
    domain: '126.com'
  action:
    modify-response:
      body: "Hello 126.com, from Video-MITM"
```

#### replace

Replacement supports simple replacement and regular replacement

##### simple replacement

```yaml
- name: "modify response body replace"
  filter:
    domain-suffix: '163.com'
  action:
    modify-response:
      body:
        origin: "Netease home page"
        new: "Video-MITM front page"
```

##### regular replacement

```yaml
- name: "modify response body regex replace"
  filter:
    domain-suffix: 'zu1k.com'
  action:
    - modify-response:
        body:
          re: '(\d{4})'
          new: 'maybe $1'

```

### MapModify - Dictionary Modifier

`MapModify` The dictionary modifier is mainly used to modify the location of the dictionary type, for example `header` and `cookies`

`key` Represents the key of the dictionary, which must be specified

`value` It is `TextModify` type, written according to the above method

If `remove` is specified as `true`, the key-value pair will be deleted

```yaml
- name: "modify response header"
  filter:
    domain: '126.com'
  action:
    - modify-response:
        header:
          key: date
          value:
            origin: "2022"
            new: "1999"
    - modify-response:
        header:
          key: new-header-item
          value: Video-MITM
    - modify-response:
        header:
          key: server
          remove: true
```

### Header modify

See the `MapModify` section method

### Cookie modify

Same as Header modification method

If `remove` is specified as `true`, the `set-cookie` item will also be removed correspondingly

### Body modify

See `TextModify` section
