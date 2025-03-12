class Translations {
  static const Map<String, String> cn = {
    'app_title': '完美切图',
    'perfect_cuts': '完美切割: {count}次',
    'start_game': '开始游戏',
    'sound_on': '打开声音',
    'sound_off': '关闭声音',
    'reset_game': '重置游戏',
    'reset_confirm_title': '重置游戏',
    'reset_confirm_message': '确定要重置所有游戏进度吗？',
    'cancel': '取消',
    'confirm': '确定',
    'perfect': '完美!',
    'language': '中/英',
    
    'select_level': '选择关卡',
    'stars': '星星',
    'perfect_count': '完美次数',
    'level': '关卡',
    'locked': '未解锁',
    
    'level_target': '目标',
    'divide_into': '将形状切成',
    'equal_parts': '等份',
    'accuracy': '准确率',
    'cut_ratio': '切割比例',
    'left_half': '左半',
    'right_half': '右半',
    'try_again': '重试',
    'next_level': '下一关',
    'back': '返回',
    'pause': '暂停',
    'resume': '继续',
    'exit_game': '退出游戏',
    'exit_confirm': '确定要退出当前关卡吗?',
    'restart': '重新开始',
    'continue_game': '继续游戏',
    'swipe_to_cut': '滑动屏幕来切割形状',
    'good_job': '做得好!',
    'excellent': '太棒了!',
    'perfect_cut': '完美切割!',
    'reset_level': '重置关卡',
  };

  static const Map<String, String> en = {
    'app_title': 'Perfect Cut',
    'perfect_cuts': 'Perfect Cuts: {count}',
    'start_game': 'Start Game',
    'sound_on': 'Sound On',
    'sound_off': 'Sound Off',
    'reset_game': 'Reset Game',
    'reset_confirm_title': 'Reset Game',
    'reset_confirm_message': 'Are you sure you want to reset all game progress?',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'perfect': 'Perfect!',
    'language': 'CN/EN',
    
    'select_level': 'Select Level',
    'stars': 'Stars',
    'perfect_count': 'Perfect Count',
    'level': 'Level',
    'locked': 'Locked',
    
    'level_target': 'Goal',
    'divide_into': 'Cut the shape into',
    'equal_parts': 'equal parts',
    'accuracy': 'Accuracy',
    'cut_ratio': 'Cutting Ratio',
    'left_half': 'Left',
    'right_half': 'Right',
    'try_again': 'Try Again',
    'next_level': 'Next Level',
    'back': 'Back',
    'pause': 'Pause',
    'resume': 'Resume',
    'exit_game': 'Exit Game',
    'exit_confirm': 'Are you sure you want to exit this level?',
    'restart': 'Restart',
    'continue_game': 'Continue',
    'swipe_to_cut': 'Swipe to cut the shape',
    'good_job': 'Good Job!',
    'excellent': 'Excellent!',
    'perfect_cut': 'Perfect Cut!',
    'reset_level': 'Reset Level',
  };
}

String tr(String key, bool isEnglish, {Map<String, String>? params}) {
  final translations = isEnglish ? Translations.en : Translations.cn;
  String text = translations[key] ?? key;
  
  if (params != null) {
    params.forEach((key, value) {
      text = text.replaceAll('{$key}', value);
    });
  }
  
  return text;
} 