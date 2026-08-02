// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTagline => '一触即发，一命通关。';

  @override
  String get play => '开始游戏';

  @override
  String get linkSkins => '皮肤';

  @override
  String get linkShop => '商店';

  @override
  String get linkStats => '统计';

  @override
  String get linkMedals => '奖章';

  @override
  String get dailyComplete => '每日任务已完成';

  @override
  String dailyLabel(String title) {
    return '每日任务：$title';
  }

  @override
  String bestScoreLabel(int score) {
    return '最高分 $score';
  }

  @override
  String get titleNovice => '新手';

  @override
  String get titleApprentice => '学徒';

  @override
  String get titleSteady => '稳健者';

  @override
  String get titleRecordHunter => '纪录猎人';

  @override
  String get titleMinimalist => '极简主义者';

  @override
  String get titleOneMore => '再来一次';

  @override
  String get titleBalance => '平衡者';

  @override
  String get titleOneMoreTry => 'One more try.';

  @override
  String get tutorialTitle => '点击切换车道';

  @override
  String get tutorialSubtitle => '躲避障碍。再试一次。';

  @override
  String get tutorialCta => '点击任意位置开始';

  @override
  String get newBest => '新纪录';

  @override
  String get dailyMissionComplete => '每日任务完成';

  @override
  String get medalUnlocked => '解锁新奖章';

  @override
  String get newSkinUnlocked => '解锁新皮肤';

  @override
  String titlePrefix(String name) {
    return '称号：$name';
  }

  @override
  String get playAgain => '再试一次';

  @override
  String get menu => '菜单';

  @override
  String get skinsTitle => '皮肤';

  @override
  String get equipped => '已装备';

  @override
  String get unlocked => '已解锁';

  @override
  String get equip => '装备';

  @override
  String unlockHintScore(int n) {
    return '最高分 ≥ $n';
  }

  @override
  String unlockHintGames(int n) {
    return '$n 局游戏';
  }

  @override
  String unlockHintDaily(int n) {
    return '$n 个每日任务';
  }

  @override
  String get shopTitle => '商店';

  @override
  String get sectionSkins => '皮肤';

  @override
  String get sectionPerks => '特权';

  @override
  String get owned => '已拥有';

  @override
  String get buy => '购买';

  @override
  String get perkActiveLabel => '已激活 — 每局自动生效';

  @override
  String perkPurchasedSnackbar(String name) {
    return '$name 已装备 — 每局自动生效';
  }

  @override
  String get medalsTitle => '奖章与称号';

  @override
  String get statsTitle => '统计';

  @override
  String get statBestScore => '最高分';

  @override
  String get statGamesPlayed => '游戏局数';

  @override
  String get statAverage20 => '平均分（最近20局）';

  @override
  String get statTimePlayed => '游戏时长';

  @override
  String statMinutes(String n) {
    return '$n 分钟';
  }

  @override
  String get statOrbsCollected => '已收集光球';

  @override
  String get statDaysPlayed => '游戏天数';

  @override
  String get statRecordsBeaten => '打破纪录次数';

  @override
  String get statDailyMissions => '每日任务';

  @override
  String get statSkinsUnlocked => '已解锁皮肤';

  @override
  String get statMedals => '奖章';

  @override
  String get statDeathsPerLane => '死亡次数 左/中/右';

  @override
  String get settingsTitle => '设置';

  @override
  String get music => '音乐';

  @override
  String get soundEffects => '音效';

  @override
  String get haptics => '震动反馈';

  @override
  String get reduceMotion => '减少动态效果';

  @override
  String get theme => '主题';

  @override
  String get themeDark => '深色';

  @override
  String get themeLight => '浅色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '系统默认';

  @override
  String get about => '关于';

  @override
  String aboutSubtitle(String appName) {
    return '$appName\n离线游戏 · 仅横幅广告 · v1.0.0';
  }

  @override
  String get credits => '鸣谢';

  @override
  String get creditsSubtitle => '美术：Shade · 菲律宾神话生物';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get privacyPolicySubtitle => '游戏进度仅保存在本设备上。AdMob 可能会根据 Google 政策收集数据。';

  @override
  String get creditsHeading => '鸣谢';

  @override
  String get pixelArtLabel => '像素美术';

  @override
  String get philippineMythCreatures => '菲律宾神话生物';

  @override
  String get byShade => '作者：Shade';

  @override
  String get cc0Note => 'CC0 协议 · 感谢使用 itch.io 素材包';

  @override
  String get viewOnItch => '在 itch.io 查看';

  @override
  String get uiArtLabel => '界面图标与商店皮肤';

  @override
  String get superRetroWorldPack => 'Super Retro World — Character Pack';

  @override
  String get bySuperRetroAuthors => '作者：Gif、Noiracide 和 Romi';

  @override
  String get superRetroLicenseNote => '署名后可免费使用 · itch.io 素材包';

  @override
  String get gameByPlanella => 'One more try. — Planella';

  @override
  String get back => '返回';

  @override
  String get loading => '加载中…';

  @override
  String get medalFirstRunName => '初次脉动';

  @override
  String get medalFirstRunDesc => '完成 1 局游戏';

  @override
  String get medalScore50Name => '觉醒';

  @override
  String get medalScore50Desc => '得分 ≥ 50';

  @override
  String get medalScore100Name => '渐入佳境';

  @override
  String get medalScore100Desc => '得分 ≥ 100';

  @override
  String get medalScore250Name => '专注';

  @override
  String get medalScore250Desc => '得分 ≥ 250';

  @override
  String get medalScore500Name => '大师';

  @override
  String get medalScore500Desc => '得分 ≥ 500';

  @override
  String get medalScore1000Name => '传奇';

  @override
  String get medalScore1000Desc => '得分 ≥ 1000';

  @override
  String get medalGames50Name => '坚持不懈';

  @override
  String get medalGames50Desc => '游戏 50 局';

  @override
  String get medalGames200Name => '习以为常';

  @override
  String get medalGames200Desc => '游戏 200 局';

  @override
  String get medalDaily3Name => '持之以恒';

  @override
  String get medalDaily3Desc => '完成 3 个每日任务';

  @override
  String get medalDaily7Name => '完美一周';

  @override
  String get medalDaily7Desc => '完成 7 个每日任务';

  @override
  String get medalNearMissName => '差一点…';

  @override
  String get medalNearMissDesc => '10 局游戏与最高分相差不到 10 分';

  @override
  String get medalNoCollectName => '纯粹主义者';

  @override
  String get medalNoCollectDesc => '得分 ≥ 150 且未收集光球';

  @override
  String get medalCoins100Name => '钱袋';

  @override
  String get medalCoins100Desc => '累计获得 10,000 枚金币';

  @override
  String get medalCoins500Name => '宝库';

  @override
  String get medalCoins500Desc => '累计获得 50,000 枚金币';

  @override
  String get missionReach80 => '单局达到 80 分';

  @override
  String get missionPlay5 => '游戏 5 局';

  @override
  String get missionOrbs30 => '收集 30 个光球';

  @override
  String get missionSurvive60 => '生存 60 秒';

  @override
  String get missionReach120 => '单局达到 120 分';

  @override
  String get perkBiggerMagnetName => '超大磁铁';

  @override
  String get perkBiggerMagnetDesc => '磁铁可以从更远处吸取道具';

  @override
  String get perkStartWithShieldName => '幸运开局';

  @override
  String get perkStartWithShieldDesc => '每局开始时自带一个护盾';

  @override
  String get perkRicherCoinsName => '金币加成';

  @override
  String get perkRicherCoinsDesc => '每枚金币额外多值 100 分';
}
