-- 11/21 SQL 练习（ry-vue 库）
-- 5 类查询，交叉验证接口测试结果

-- ① SELECT 基础查询
SELECT user_id, user_name, nick_name FROM sys_user;

-- ② WHERE 条件查询
SELECT user_name, phonenumber FROM sys_user WHERE user_name = 'admin';
SELECT user_id, user_name FROM sys_user WHERE user_name LIKE '%test%';
SELECT user_name, status FROM sys_user WHERE status = '0' AND user_id > 1;

-- ③ GROUP BY 分组统计
SELECT dept_id, COUNT(*) AS cnt FROM sys_user GROUP BY dept_id;

-- ④ JOIN 联表查询
SELECT u.user_name, d.dept_name FROM sys_user u LEFT JOIN sys_dept d ON u.dept_id = d.dept_id;

-- ⑤ 交叉验证（接口新增/修改的数据是否落库）
SELECT * FROM sys_user WHERE user_name = 'test_api01';
SELECT user_name, nick_name FROM sys_user WHERE user_id = 101;
