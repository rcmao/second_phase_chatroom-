#!/usr/bin/env python3
"""
测试沉默提醒修复效果
"""
import sys
import time
from smart_intervention_engine import SmartInterventionEngine

def test_silence_fix():
    """测试沉默检测修复"""
    print("🧪 开始测试沉默提醒修复...")
    
    # 创建引擎实例
    engine = SmartInterventionEngine()
    room_id = "test_room"
    current_time = time.time()
    
    # 模拟活跃讨论 - 最近60秒内有多个用户发言
    print("\n📝 模拟活跃讨论场景...")
    
    # 添加最近的消息
    messages = [
        {'user_id': 'user1', 'username': 'Lily', 'content': '皇马', 'timestamp': current_time - 30, 'gender': 'female'},
        {'user_id': 'user2', 'username': 'Steve', 'content': '热刺必须滴', 'timestamp': current_time - 20, 'gender': 'male'},
        {'user_id': 'user1', 'username': 'Lily', 'content': '个人认为曼联，利物浦，巴萨这三个从足球哲学上来说可以排第一', 'timestamp': current_time - 10, 'gender': 'female'},
        {'user_id': 'user2', 'username': 'Steve', 'content': '你觉得和什么有关', 'timestamp': current_time - 5, 'gender': 'male'},
    ]
    
    # 将消息添加到引擎
    for msg in messages:
        engine._update_user_state(
            room_id, msg['user_id'], msg['username'], 
            msg['content'], msg['gender'], msg['timestamp']
        )
    
    # 测试活跃讨论检测
    is_active = engine._is_active_discussion(room_id)
    print(f"🔍 活跃讨论检测结果: {is_active}")
    
    # 测试沉默检测 - 在活跃讨论中不应该触发
    print("\n🤐 测试沉默检测...")
    silence_result = engine._check_silence_intervention(room_id)
    print(f"🔍 沉默检测结果: {silence_result}")
    
    # 测试其他干预检测
    print("\n🔄 测试综合干预检测...")
    other_result = engine._check_other_interventions(room_id, current_time)
    print(f"🔍 其他干预检测结果: {other_result}")
    
    # 输出总结
    print("\n📊 测试总结:")
    print(f"   - 活跃讨论: {'✅ 检测到' if is_active else '❌ 未检测到'}")
    print(f"   - 沉默干预: {'❌ 意外触发' if silence_result else '✅ 正确阻止'}")
    print(f"   - 其他干预: {'⚠️ 有干预' if other_result else '✅ 无干预'}")
    
    if is_active and not silence_result and not other_result:
        print("\n🎉 测试通过！沉默提醒修复成功！")
        return True
    else:
        print("\n❌ 测试失败，需要进一步检查")
        return False

if __name__ == "__main__":
    success = test_silence_fix()
    sys.exit(0 if success else 1)
