package com.sky;

import com.sky.entity.Orders;
import com.sky.entity.OrderDetail;
import com.sky.mapper.OrdersMapper;
import com.sky.mapper.OrderDetailMapper;
import com.sky.mapper.UserMapper;
import com.sky.mapper.AddressBookMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 创建测试订单数据的工具类
 */
@SpringBootTest
public class CreateTestOrders {

    @Autowired
    private OrdersMapper ordersMapper;

    @Autowired
    private OrderDetailMapper orderDetailMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private AddressBookMapper addressBookMapper;

    @Test
    @Transactional
    public void createTestOrders() {
        System.out.println("开始创建测试订单数据...");

        // 创建多个测试订单
        for (int i = 1; i <= 5; i++) {
            createSingleOrder(i);
        }

        System.out.println("测试订单数据创建完成！");
    }

    private void createSingleOrder(int index) {
        try {
            // 1. 创建订单主表数据
            Orders order = new Orders();
            order.setNumber(System.currentTimeMillis() + String.format("%03d", index));
            order.setStatus(getRandomStatus());
            order.setUserId(1L); // 假设用户ID为1
            order.setUserName("测试用户" + index);
            order.setAddressBookId(1L); // 假设地址ID为1
            order.setOrderTime(LocalDateTime.now().minusHours(index));
            
            if (order.getStatus() != 1) { // 如果不是待付款状态
                order.setCheckoutTime(LocalDateTime.now().minusHours(index - 1));
            }
            
            order.setPayMethod(1); // 微信支付
            order.setPayStatus(order.getStatus() > 1 ? 1 : 0); // 已支付或未支付
            order.setAmount(getRandomAmount());
            order.setRemark("测试订单备注 " + index);
            order.setPhone("1380013800" + index);
            order.setAddress("测试地址 " + index);
            order.setConsignee("测试收货人" + index);
            order.setEstimatedDeliveryTime(LocalDateTime.now().plusHours(index));
            order.setDeliveryStatus(1);
            order.setPackAmount(2);
            order.setTablewareNumber(index);
            order.setTablewareStatus(0);

            // 2. 插入订单数据
            ordersMapper.insert(order);
            Long orderId = order.getId();

            // 3. 创建订单明细
            List<OrderDetail> orderDetailList = new ArrayList<>();
            
            // 创建2-3个订单明细
            int detailCount = 2 + (index % 2);
            for (int j = 1; j <= detailCount; j++) {
                OrderDetail detail = new OrderDetail();
                detail.setName("测试菜品" + index + "-" + j);
                detail.setImage("https://example.com/dish" + index + "-" + j + ".jpg");
                detail.setOrderId(orderId);
                detail.setDishId((long) (index * 10 + j));
                detail.setSetmealId(null);
                detail.setDishFlavor(getRandomFlavor());
                detail.setNumber(1 + (j % 3));
                detail.setAmount(new BigDecimal(20 + (j * 10)));
                orderDetailList.add(detail);
            }

            // 4. 插入订单明细
            orderDetailMapper.insertBatch(orderDetailList);

            System.out.println("创建订单成功: ID=" + orderId + ", 订单号=" + order.getNumber() + 
                             ", 状态=" + getStatusDesc(order.getStatus()) + ", 金额=" + order.getAmount());

        } catch (Exception e) {
            System.err.println("创建订单失败: " + e.getMessage());
        }
    }

    private Integer getRandomStatus() {
        // 随机生成订单状态：1-6
        int[] statuses = {1, 2, 3, 4, 5, 6};
        return statuses[(int) (Math.random() * statuses.length)];
    }

    private BigDecimal getRandomAmount() {
        // 随机生成金额：30-200之间
        double amount = 30 + Math.random() * 170;
        return new BigDecimal(String.format("%.2f", amount));
    }

    private String getRandomFlavor() {
        String[] flavors = {"不要辣", "微辣", "中辣", "重辣", "少盐", "正常", ""};
        return flavors[(int) (Math.random() * flavors.length)];
    }

    private String getStatusDesc(Integer status) {
        switch (status) {
            case 1: return "待付款";
            case 2: return "待接单";
            case 3: return "已接单";
            case 4: return "派送中";
            case 5: return "已完成";
            case 6: return "已取消";
            default: return "未知状态";
        }
    }
}
