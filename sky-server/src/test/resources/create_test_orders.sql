-- 创建订单假数据的SQL脚本

-- 1. 首先确保有用户数据（如果没有的话）
INSERT IGNORE INTO user (id, openid, name, phone, sex, id_number, avatar, create_time) VALUES 
(1, 'test_openid_001', '测试用户1', '13800138001', '1', '110101199001011234', 'https://example.com/avatar1.jpg', NOW()),
(2, 'test_openid_002', '测试用户2', '13800138002', '0', '110101199002022345', 'https://example.com/avatar2.jpg', NOW()),
(3, 'test_openid_003', '测试用户3', '13800138003', '1', '110101199003033456', 'https://example.com/avatar3.jpg', NOW());

-- 2. 确保有地址簿数据
INSERT IGNORE INTO address_book (id, user_id, consignee, phone, sex, province_code, province_name, city_code, city_name, district_code, district_name, detail, label, is_default) VALUES 
(1, 1, '张三', '13800138001', '1', '110000', '北京市', '110100', '北京市', '110101', '东城区', '测试地址1号', '家', 1),
(2, 2, '李四', '13800138002', '0', '110000', '北京市', '110100', '北京市', '110102', '西城区', '测试地址2号', '公司', 1),
(3, 3, '王五', '13800138003', '1', '110000', '北京市', '110100', '北京市', '110105', '朝阳区', '测试地址3号', '学校', 1);

-- 3. 插入订单数据
INSERT INTO orders (
    number, status, user_id, user_name, address_book_id, order_time, checkout_time, 
    pay_method, pay_status, amount, remark, phone, address, consignee, 
    estimated_delivery_time, delivery_status, pack_amount, tableware_number, tableware_status
) VALUES 
(
    CONCAT('ORDER', UNIX_TIMESTAMP(), '001'), 2, 1, '测试用户1', 1, 
    NOW() - INTERVAL 2 HOUR, NOW() - INTERVAL 1 HOUR, 
    1, 1, 68.00, '不要辣', '13800138001', '测试地址1号', '张三',
    NOW() + INTERVAL 1 HOUR, 1, 2, 1, 0
),
(
    CONCAT('ORDER', UNIX_TIMESTAMP(), '002'), 3, 2, '测试用户2', 2, 
    NOW() - INTERVAL 1 HOUR, NOW() - INTERVAL 30 MINUTE, 
    1, 1, 98.00, '少盐', '13800138002', '测试地址2号', '李四',
    NOW() + INTERVAL 2 HOUR, 1, 2, 2, 0
),
(
    CONCAT('ORDER', UNIX_TIMESTAMP(), '003'), 4, 3, '测试用户3', 3, 
    NOW() - INTERVAL 30 MINUTE, NOW() - INTERVAL 15 MINUTE, 
    2, 1, 128.00, '微辣', '13800138003', '测试地址3号', '王五',
    NOW() + INTERVAL 30 MINUTE, 1, 3, 1, 1
),
(
    CONCAT('ORDER', UNIX_TIMESTAMP(), '004'), 5, 1, '测试用户1', 1, 
    NOW() - INTERVAL 4 HOUR, NOW() - INTERVAL 3 HOUR, 
    1, 1, 76.00, '正常口味', '13800138001', '测试地址1号', '张三',
    NOW(), 1, 2, 1, 0
),
(
    CONCAT('ORDER', UNIX_TIMESTAMP(), '005'), 6, 2, '测试用户2', 2, 
    NOW() - INTERVAL 20 MINUTE, NULL, 
    1, 0, 85.50, '超时取消', '13800138002', '测试地址2号', '李四',
    NULL, 1, 2, 1, 0
);

-- 4. 插入订单明细数据
-- 获取刚刚插入的订单ID（需要根据实际情况调整）
SET @order1_id = (SELECT id FROM orders WHERE user_id = 1 ORDER BY order_time DESC LIMIT 1);
SET @order2_id = (SELECT id FROM orders WHERE user_id = 2 AND status = 3 ORDER BY order_time DESC LIMIT 1);
SET @order3_id = (SELECT id FROM orders WHERE user_id = 3 ORDER BY order_time DESC LIMIT 1);
SET @order4_id = (SELECT id FROM orders WHERE user_id = 1 AND status = 5 ORDER BY order_time DESC LIMIT 1);

-- 插入订单明细
INSERT INTO order_detail (name, image, order_id, dish_id, setmeal_id, dish_flavor, number, amount) VALUES 
('宫保鸡丁', 'https://example.com/dish1.jpg', @order1_id, 1, NULL, '不要辣', 1, 28.00),
('米饭', 'https://example.com/dish2.jpg', @order1_id, 2, NULL, '', 2, 12.00),
('可乐', 'https://example.com/dish3.jpg', @order1_id, 3, NULL, '', 1, 8.00),

('红烧肉', 'https://example.com/dish4.jpg', @order2_id, 4, NULL, '少盐', 2, 56.00),
('青菜', 'https://example.com/dish5.jpg', @order2_id, 5, NULL, '', 1, 18.00),

('宫保鸡丁', 'https://example.com/dish1.jpg', @order3_id, 1, NULL, '微辣', 2, 56.00),
('麻婆豆腐', 'https://example.com/dish6.jpg', @order3_id, 6, NULL, '', 1, 22.00),
('套餐A', 'https://example.com/setmeal1.jpg', @order3_id, NULL, 1, '', 1, 50.00),

('鱼香肉丝', 'https://example.com/dish7.jpg', @order4_id, 7, NULL, '正常口味', 1, 32.00),
('蛋炒饭', 'https://example.com/dish8.jpg', @order4_id, 8, NULL, '', 1, 18.00),
('汤', 'https://example.com/dish9.jpg', @order4_id, 9, NULL, '', 1, 12.00);

-- 查看插入结果
SELECT 
    o.id as 订单ID,
    o.number as 订单号,
    o.status as 订单状态,
    o.user_name as 用户名,
    o.amount as 金额,
    o.order_time as 下单时间,
    CASE o.status
        WHEN 1 THEN '待付款'
        WHEN 2 THEN '待接单'
        WHEN 3 THEN '已接单'
        WHEN 4 THEN '派送中'
        WHEN 5 THEN '已完成'
        WHEN 6 THEN '已取消'
        ELSE '未知状态'
    END as 状态描述
FROM orders o 
WHERE o.number LIKE CONCAT('ORDER', UNIX_TIMESTAMP() - 3600, '%')
ORDER BY o.order_time DESC;
