-- 修复admin用户密码问题
-- 问题：数据库中admin用户的密码存储为明文"123456"，但代码逻辑要求密码必须MD5加密后存储
-- 解决方案：将admin用户的密码更新为MD5加密后的值

-- MD5('123456') = e10adc3949ba59abbe56e057f20f883e
UPDATE employee
SET password = 'e10adc3949ba59abbe56e057f20f883e'
WHERE username = 'admin';

-- 验证修复结果
SELECT id, name, username, password, status
FROM employee
WHERE username = 'admin';

-- 注意：这是正确的做法，因为：
-- 1. 密码在数据库中应该加密存储（安全要求）
-- 2. 代码逻辑也是按照加密方式设计的
-- 3. 修复数据使之符合代码逻辑，而不是修改代码来适应错误数据
