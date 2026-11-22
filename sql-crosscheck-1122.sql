-- 11月22日 SQL 交叉验证 5 组（若依 RuoYi-Vue / 数据库 ry-vue）
-- 用法：DBeaver 连接注意主机填 127.0.0.1（localhost 会被今天启动的禅道 MySQL 抢占解析）
-- 验证思路：网页界面操作 → 写 SQL 查库 → 两边结果一致，证明数据真的落库

-- 【第1组】界面新增用户 test_ui01 → 查库
-- 网页操作：系统管理→用户管理→新增，填 test_ui01 / 界面新增测试 / 13900139001
-- 预期：查出 test_ui01 / 界面新增测试 / 13900139001
SELECT user_id, user_name, nick_name, phonenumber FROM sys_user WHERE user_name = 'test_ui01';

-- 【第2组】界面改手机号 → 查库
-- 网页操作：编辑 test_ui01，手机号改成 13900139009
-- 预期：phonenumber 变成 13900139009
SELECT user_name, nick_name, phonenumber FROM sys_user WHERE user_name = 'test_ui01';

-- 【第3组】界面删除 → 查库（若依是逻辑删除，del_flag 从 0 改成 2）
-- 网页操作：删除 test_ui01，列表里消失
-- 预期：查出 del_flag = 2，证明删除已生效（数据保留但打标记）
SELECT user_id, user_name, nick_name, del_flag FROM sys_user WHERE user_name = 'test_ui01';
-- 或者：查正常用户里已经没有它 → 0 行
SELECT user_id, user_name FROM sys_user WHERE user_name = 'test_ui01' AND del_flag = '0';

-- 【第4组】搜索 → 比对条数
-- 网页操作：用户名称搜 test → 显示 1 条（test_api01）
-- 预期：数量 = 1（test_api02、test_ui01 都已逻辑删除，被过滤）
SELECT COUNT(*) AS 数量 FROM sys_user WHERE user_name LIKE '%test%' AND del_flag = '0';

-- 【第5组】分页 → 比对 total
-- 网页操作：点重置看全部用户 → 左下角"共 3 条"（admin、ry、test_api01）
-- 预期：总数 = 3
SELECT COUNT(*) AS 总数 FROM sys_user WHERE del_flag = '0';

-- ============================================================
-- 面试知识点：逻辑删除
-- 问："删除用户后数据库里还有吗？"
-- 答："若依用逻辑删除，不物理删除。del_flag=0 正常，=2 已删除。
--      数据行保留便于恢复和追溯，网页查询自动过滤 del_flag=2 的记录。"
-- ============================================================
