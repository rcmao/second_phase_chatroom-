#!/usr/bin/env python3
"""
测试最终修复效果
"""
import time
from smart_intervention_engine import SmartInterventionEngine

def test_silence_fix():
    """测试沉默检测修复"""
    print("🧪 测试沉默提醒修复...")
    
    engine = SmartInterventionEngine()
    room_id = "test_room"
    current_time = time.time()
    
    # 场景1: 活跃讨论中不应该触发沉默检测
    print("\n📝 场景1: 模拟活跃讨论...")
    messages = [
        {'user_id': 'user1', 'username': 'Lily', 'content': '皇马', 'timestamp': current_time - 30, 'gender': 'female'},
        {'user_id': 'user2', 'username': 'Steve', 'content': '热刺必须滴', 'timestamp': current_time - 25, 'gender': 'male'},
        {'user_id': 'user1', 'username': 'Lily', 'content': '个人认为曼联，利物浦，巴萨这三个从足球哲学上来说可以排第一', 'timestamp': current_time - 20, 'gender': 'female'},
        {'user_id': 'user2', 'username': 'Steve', 'content': '你觉得和什么有关', 'timestamp': current_time - 15, 'gender': 'male'},
        {'user_id': 'user1', 'username': 'Lily', 'content': '球哲学应该与成绩，与打法的观赏性无关', 'timestamp': current_time - 10, 'gender': 'female'},
    ]
    
    for msg in messages:
        engine._update_user_state(room_id, msg['user_id'], msg['username'], msg['content'], msg['gender'], msg['timestamp'])
    
    # 检查活跃讨论状态
    is_active = engine._is_active_discussion(room_id)
    print(f"🔍 活跃讨论检测: {is_active}")
    
    # 检查是否会触发沉默检测
    other_result = engine._check_other_interventions(room_id, current_time)
    print(f"🔍 干预检测结果: {other_result}")
    
    if is_active and not other_result:
        print("✅ 场景1通过: 活跃讨论中正确阻止了沉默检测")
        scenario1_pass = True
    else:
        print("❌ 场景1失败: 活跃讨论中仍然触发了沉默检测")
        scenario1_pass = False
    
    # 场景2: 非活跃讨论中应该触发沉默检测
    print("\n📝 场景2: 模拟沉默场景...")
    engine2 = SmartInterventionEngine()
    room_id2 = "test_room_2"
    
    # 添加较早的消息
    old_messages = [
        {'user_id': 'user1', 'username': 'Alice', 'content': '大家好', 'timestamp': current_time - 300, 'gender': 'female'},
        {'user_id': 'user2', 'username': 'Bob', 'content': '你好', 'timestamp': current_time - 280, 'gender': 'male'},
        {'user_id': 'user3', 'username': 'Charlie', 'content': '今天天气不错', 'timestamp': current_time - 260, 'gender': 'male'},
        {'user_id': 'user1', 'username': 'Alice', 'content': '是的', 'timestamp': current_time - 240, 'gender': 'female'},
        {'user_id': 'user2', 'username': 'Bob', 'content': '我们聊点别的吧', 'timestamp': current_time - 220, 'gender': 'male'},
        {'user_id': 'user3', 'username': 'Charlie', 'content': '好的', 'timestamp': current_time - 200, 'gender': 'male'},
        {'user_id': 'user1', 'username': 'Alice', 'content': '那就这样吧', 'timestamp': current_time - 120, 'gender': 'female'},
    ]
    
    for msg in old_messages:
        engine2._update_user_state(room_id2, msg['user_id'], msg['username'], msg['content'], msg['gender'], msg['timestamp'])
    
    is_active2 = engine2._is_active_discussion(room_id2)
    print(f"🔍 活跃讨论检测: {is_active2}")
    
    silence_result = engine2._check_silence_intervention(room_id2)
    print(f"🔍 沉默检测结果: {'有' if silence_result else '无'}")
    
    if not is_active2 and silence_result:
        print("✅ 场景2通过: 非活跃讨论中正确触发了沉默检测")
        scenario2_pass = True
    else:
        print("❌ 场景2失败: 非活跃讨论中未能触发沉默检测")
        scenario2_pass = False
    
    # 总结
    print(f"\n📊 测试总结:")
    print(f"   场景1 (活跃讨论阻止沉默检测): {'✅ 通过' if scenario1_pass else '❌ 失败'}")
    print(f"   场景2 (非活跃讨论触发沉默检测): {'✅ 通过' if scenario2_pass else '❌ 失败'}")
    
    if scenario1_pass and scenario2_pass:
        print("\n🎉 所有测试通过！沉默提醒修复成功！")
        return True
    else:
        print("\n❌ 部分测试失败，需要进一步调试")
        return False

if __name__ == "__main__":
    success = test_silence_fix()
    exit(0 if success else 1)
