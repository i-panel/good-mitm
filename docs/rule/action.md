# Action

`Action` Used to operate on requests or returns

## candidate

`Action` Currently includes the following options：

- Reject
- Redirect(String)
- ModifyRequest(Modify)
- ModifyResponse(Modify)
- LogRes
- LogReq

### Reject

`reject` type directly returns `502`，Used to reject certain requests, can be used to reject tracking and advertising

```yaml
- name: "reject CSDN"
  filter:
    domain-keyword: 'csdn'
  action: reject
```

### Redirect 

`redirect`type directly returns`302`redirect

```yaml
- name: "youtube-1"
  filter:
    url-regex: '(^https?:\/\/(?!redirector)[\w-]+\.googlevideo\.com\/(?!dclk_video_ads).+)(ctier=L)(&.+)'
  action:
    redirect: "$1$4"
```

### ModifyRequest 

`modify-request` Used to modify the request, see the specific modification rules [modifier](rule/modify.md)

### ModifyResponse 

`modify-response`It is used to modify the return, see the specific modification rules [modifier](rule/modify.md)

### Log 

`log-req` used to log requests，`log-res` used to log back

## Multiple Actions

`actions`Field supports single action and multiple actions，Arrays should be used when multiple actions need to be performed

```yaml
- name: "youtube-1"
  filter:
    url-regex: '(^https?:\/\/(?!redirector)[\w-]+\.googlevideo\.com\/(?!dclk_video_ads).+)(ctier=L)(&.+)'
  actions:
    - log-req:
    - redirect: "$1$4"
```
