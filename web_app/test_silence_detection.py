#!/usr/bin/env python3
"""
测试真正沉默时的检测是否仍然工作
"""
import sys
import time
from smart_intervention_engine import SmartInterventionEngine

def test_real_silence():
    """测试真正沉默时的检测"""
    print("🧪 测试真正沉默场景的检测...")
    
    # 创建引擎实例
    engine = SmartInterventionEngine()
    room_id = "test_room_silence"
    current_time = time.time()
    
    # 模拟非活跃讨论 - 很久之前的消息，现在没人说话
    print("\n📝 模拟沉默场景...")
    
    # 添加较早的消息，让用户有足够的对话历史
    messages = [
        {'user_id': 'user1', 'username': 'Alice', 'content': '大家好', 'timestamp': current_time - 300, 'gender': 'female'},
        {'user_id': 'user2', 'username': 'Bob', 'content': '你好', 'timestamp': current_time - 290, 'gender': 'male'},
        {'user_id': 'user3', 'username': 'Charlie', 'content': '今天天气不错', 'timestamp': current_time - 280, 'gender': 'male'},
        {'user_id': 'user1', 'username': 'Alice', 'content': '是的', 'timestamp': current_time - 270, 'gender': 'female'},
        {'user_id': 'user2', 'username': 'Bob', 'content': '我们聊点别的吧', 'timestamp': current_time - 260, 'gender': 'male'},
        {'user_id': 'user3', 'username': 'Charlie', 'content': '好的', 'timestamp': current_time - 250, 'gender': 'male'},
        # 最后一条消息是120秒前，超过了沉默阈值
        {'user_id': 'user1', 'username': 'Alice', 'content': '那就这样吧', 'timestamp': current_time - 120, 'gender': 'female'},
    ]
    
    # 注意：引擎会从消息记录中推断在线用户
    
    # 将消息添加到引擎
    for msg in messages:
        engine._update_user_state(
            room_id, msg['user_id'], msg['username'], 
            msg['content'], msg['gender'], msg['timestamp']
        )
    
    # 测试活跃讨论检测 - 应该为False（因为最近60秒内没有足够消息）
    is_active = engine._is_active_discussion(room_id)
    print(f"🔍 活跃讨论检测结果: {is_active}")
    
    # 测试沉默检测 - 应该能检测到沉默用户
    print("\n🤐 测试沉默检测...")
    silence_result = engine._check_silence_intervention(room_id)
    print(f"🔍 沉默检测结果: {silence_result}")
    
    # 测试其他干预检测
    print("\n🔄 测试综合干预检测...")
    other_result = engine._check_other_interventions(room_id, current_time)
    print(f"🔍 其他干预检测结果: {other_result}")
    
    # 输出总结
    print("\n📊 测试总结:")
    print(f"   - 活跃讨论: {'❌ 意外检测到' if is_active else '✅ 正确未检测到'}")
    print(f"   - 沉默干预: {'✅ 正确触发' if silence_result else '❌ 未触发'}")
    
    if not is_active and silence_result:
        print("\n🎉 沉默检测正常工作！")
        return True
    else:
        print("\n❌ 沉默检测可能有问题")
        return False

if __name__ == "__main__":
    success = test_real_silence()
    sys.exit(0 if success else 1)
