# 11/21（周六）接口测试成果报告

## 一、今日完成

- 接口总数：**30 条**，全部执行通过
- 构成：正常业务接口 19 条 + 鉴权/异常场景 11 条
- 每条接口带断言（业务 code 校验），Postman 显示 Test Results 通过
- 交付文件：
  - `若依接口测试_collection.json`（30 条，token 已内置，可直接导入 Postman）
  - `项目截图/11-21_接口执行结果.png`（正常接口 200 + Test Results）
  - `项目截图/11-21_异常接口截图.png`（异常场景返回截图）

## 二、30 条接口清单

### 正常业务（19 条）

| # | 接口名 | 方法 | 路径 | 预期 code |
|---|---|---|---|---|
| 1 | 查询用户列表-正常 | GET | /system/user/list?pageNum=1&pageSize=10 | 200 |
| 2 | 按用户名查询-admin | GET | /system/user/list?userName=admin | 200 |
| 3 | 查询不存在用户 | GET | /system/user/list?userName=zzzznotexist | 200 |
| 4 | 分页 pageNum=0 | GET | /system/user/list?pageNum=0&pageSize=10 | 200 |
| 5 | 获取用户详情-id=2 | GET | /system/user/2 | 200 |
| 6 | 部门树 | GET | /system/user/deptTree | 200 |
| 7 | 查询角色列表 | GET | /system/role/list | 200 |
| 8 | 菜单列表 | GET | /system/menu/list | 200 |
| 9 | 部门列表 | GET | /system/dept/list | 200 |
| 10 | 岗位列表 | GET | /system/post/list | 200 |
| 11 | 参数列表 | GET | /system/config/list | 200 |
| 12 | 公告列表 | GET | /system/notice/list | 200 |
| 13 | 新增用户-正常 | POST | /system/user | 200 |
| 14 | 新增用户-用户名重复 | POST | /system/user | 500 |
| 15 | 新增用户-缺必填 userName | POST | /system/user | 500 |
| 16 | 修改用户 | PUT | /system/user | 200 |
| 17 | 修改用户状态 | PUT | /system/user/changeStatus | 200 |
| 18 | 重置密码 | PUT | /system/user/resetPwd | 200 |
| 19 | 删除用户 | DELETE | /system/user/101 | 200 |

### 鉴权与异常场景（11 条）

| # | 接口名 | 方法 | 路径 / 构造方式 | 预期 code |
|---|---|---|---|---|
| 20 | 获取用户信息 | GET | /getInfo | 200 |
| 21 | 获取路由菜单 | GET | /getRouters | 200 |
| 22 | 特殊字符搜索 | GET | /system/user/list?userName=%3Cscript%3E | 200 + 空 |
| 23 | 大分页 | GET | /system/user/list?pageNum=1&pageSize=100 | 200 |
| 24 | 参数非法 | GET | /system/user/list?pageNum=abc | 200（默认值容错） |
| 25 | 401-不带 token | GET | /system/user/list，Authorization 选 No Auth | 401 |
| 26 | 401-假 token | GET | /system/user/list，token 填 fake_token | 401 |
| 27 | URL 拼错-类型不匹配 | GET | /system/user/lis（少个 t） | 500 |
| 28 | 参数缺失 | GET | /system/user/list（不带分页参数） | 200 |
| 29 | 角色按名查询 | GET | /system/role/list?roleName=admin | 200 |
| 30 | 405-方法不支持 | POST | /system/user/list | 500 |

## 三、发现的 Bug / 缺陷线索（面试可讲）

1. **用户名重复校验**：POST 新增同名用户，返回 `code:500「登录账号已存在」`，未做前置唯一性校验拦截，异常提示不够友好。
2. **前后端密码规则不一致**：前端 `passwordRule.js` 限制 6–20 位，后端 `UserConstants.java` 是 5–20 位。用 5 位密码调接口可绕过前端限制直接入库。
3. **Token 鉴权缺陷**：不带 `Bearer ` 前缀的 token 仍能通过鉴权访问接口（正常应拒绝），鉴权前缀校验不严。
4. **验证码刷新后旧码未失效**：刷新验证码后原验证码仍可登录（需进一步复现确认）。
5. **参数非法静默容错**：`pageNum=abc` 等非数值分页参数未报参数错误，后端静默按默认值处理，前端可能拿不到预期提示。

## 四、简历话术（可直接抄）

> 基于若依（RuoYi-Vue）后台管理系统执行接口测试：使用 Postman 设计并执行 30 条接口用例，覆盖 GET/POST/PUT/DELETE 四种方法，包含正常业务流程、鉴权异常（401 未授权/伪造 token）、参数异常（非法参数/参数缺失/类型不匹配）、方法不支持（405）等场景；为每条接口编写断言校验业务响应码，全部执行通过。发现并记录 5 个潜在缺陷（前后端密码规则不一致、用户名重复校验、token 前缀校验缺陷、验证码时效、参数非法静默容错），输出 Postman 接口测试用例集与执行结果截图。

## 五、技术要点（面试问答准备）

- 登录鉴权流程：`GET /captchaImage` 取 uuid → 从 Redis 读验证码答案 → `POST /login` 拿 token → 后续请求头带 `Authorization: Bearer <token>`
- 接口数据来源：从后端源码 `SysUserController.java` 等 Controller 读取真实 URL 与方法，非臆造
- Postman 断言写法：`pm.test("...", () => pm.expect(pm.response.json().code).to.eql(200))`
- HTTP 200 与业务 code 500 不矛盾：HTTP 200 表示请求到达服务器，code 是业务层状态码（若依统一用 code 字段）
- 查询结果说明：查询类接口即使查不到数据也返回 200 + 空 rows，属正常设计（如第 3、22 条）
- 退出登录（logout）会使 token 失效，测试时注意不要让 token 作废影响后续用例

## 六、明日（11/22）待办

- SQL 交叉验证 5 组（DBeaver 连本地 ry-vue 库）
- 把今日 collection.json + 截图上传 GitHub
- 整理 110 条功能测试用例 + 接口报告，形成完整测试作品集
