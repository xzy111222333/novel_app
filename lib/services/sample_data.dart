import 'package:uuid/uuid.dart';
import '../models/material_item.dart';
import '../models/vocabulary_item.dart';
import '../models/inspiration_item.dart';
import '../models/plot_item.dart';

class SampleData {
  static final _uuid = Uuid();

  static const List<String> materialCategories = [
    '全部', '对话', '动作描写', '心理描写', '人物描写', '环境描写',
  ];

  static const List<String> vocabularyCategories = [
    '全部', '环境', '外貌', '神态', '声音', '动作', '心理',
  ];

  static const List<String> plotCategories = [
    '全部', '打脸剧情', '总裁剧情', '宫斗剧情', '甜宠剧情', '校园剧情', '装逼剧情', '憋屈剧情', '未婚先孕',
  ];

  static List<MaterialItem> getMaterials() {
    final now = DateTime.now();
    return [
      MaterialItem(
        id: _uuid.v4(),
        content: '"你以为你赢了？"她冷笑一声，眼底划过一丝不易察觉的狠厉，"不过是我还没出手罢了。"',
        category: '对话',
        tags: ['反派', '女性角色', '冷酷'],
        source: '原创',
        isFavorite: true,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      MaterialItem(
        id: _uuid.v4(),
        content: '"我等了你三年，"他的声音低沉而沙哑，"你却告诉我，这一切不过是一场戏？"',
        category: '对话',
        tags: ['男主', '深情', '虐心'],
        source: '原创',
        isFavorite: false,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      MaterialItem(
        id: _uuid.v4(),
        content: '他猛地拔出长剑，剑身在月光下泛着冷冽的寒光。脚尖一点，身形如鬼魅般掠过三丈远，剑锋直指对方咽喉。',
        category: '动作描写',
        tags: ['武打', '古风', '男主'],
        source: '原创',
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      MaterialItem(
        id: _uuid.v4(),
        content: '她的拳头攥得发白，指甲深深嵌入掌心，却浑然不觉。胸口像是被什么东西堵住了，喘不上气来，泪水在眼眶里打转，却倔强地不肯落下。',
        category: '心理描写',
        tags: ['女主', '隐忍', '虐心'],
        source: '原创',
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      MaterialItem(
        id: _uuid.v4(),
        content: '他身形修长，一袭月白长衫衬得他如谪仙临尘。剑眉星目间自带三分清冷，薄唇微抿时却又透出几分少年意气。',
        category: '人物描写',
        tags: ['男主', '古风', '外貌'],
        source: '原创',
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      MaterialItem(
        id: _uuid.v4(),
        content: '暮色四合，远山如黛。一弯新月挂在枝头，洒下清冷的银辉。古寺的钟声悠悠传来，在空寂的山谷间回荡，平添几分苍凉。',
        category: '环境描写',
        tags: ['古风', '夜景', '意境'],
        source: '原创',
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 2, hours: 6)),
      ),
      MaterialItem(
        id: _uuid.v4(),
        content: '她看起来不过十七八岁的模样，一双杏眼清澈如水，鼻尖微翘，嘴角总是挂着一抹若有似无的笑意，让人不由自主地想要亲近。',
        category: '人物描写',
        tags: ['女主', '外貌', '甜美'],
        source: '原创',
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      MaterialItem(
        id: _uuid.v4(),
        content: '雨后的小巷弥漫着青石板特有的潮湿气息，墙角的苔藓绿得发亮。远处传来几声犬吠，老槐树上的知了不知疲倦地叫着，一切都慵懒而安详。',
        category: '环境描写',
        tags: ['现代', '小镇', '夏天'],
        source: '原创',
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
      ),
      MaterialItem(
        id: _uuid.v4(),
        content: '他的心像是被人狠狠攥住，每跳动一下都带着钝痛。明明近在咫尺，却觉得她离自己越来越远，远到再也触不可及。',
        category: '心理描写',
        tags: ['男主', '暗恋', '虐心'],
        source: '原创',
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  static List<VocabularyItem> getVocabulary() {
    final now = DateTime.now();
    return [
      VocabularyItem(
        id: _uuid.v4(),
        content: '幽暗的房间',
        category: '环境',
        tags: ['氛围', '室内'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '弯弯的眉毛像月牙',
        category: '外貌',
        tags: ['比喻', '女性'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '清冷的目光',
        category: '神态',
        tags: ['冷酷', '眼神'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '月光倾泻如水银',
        category: '环境',
        tags: ['夜景', '比喻'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '声音低沉而沙哑',
        category: '声音',
        tags: ['男性', '嗓音'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '笑意不达眼底',
        category: '神态',
        tags: ['伪装', '心机'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '风卷残云般席卷而过',
        category: '动作',
        tags: ['速度', '比喻'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '眼眶微微泛红',
        category: '神态',
        tags: ['情绪', '悲伤'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '薄唇轻抿成一条线',
        category: '外貌',
        tags: ['男性', '冷峻'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '心如刀绞般疼痛',
        category: '心理',
        tags: ['痛苦', '比喻'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 3, hours: 1)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '桃花瓣纷纷扬扬',
        category: '环境',
        tags: ['春天', '古风'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      VocabularyItem(
        id: _uuid.v4(),
        content: '眉目如画',
        category: '外貌',
        tags: ['古风', '美貌'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 4, hours: 5)),
      ),
    ];
  }

  static List<InspirationItem> getInspirations() {
    final now = DateTime.now();
    return [
      InspirationItem(
        id: _uuid.v4(),
        title: '双重身份的女主',
        content: '女主白天是温顺的世家小姐，夜晚却化身为江湖上令人闻风丧胆的暗夜杀手。当她被迫嫁给敌对家族的少主时，两个身份之间的冲突开始白热化……',
        tags: ['古风', '双面', '女强'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      InspirationItem(
        id: _uuid.v4(),
        title: '失忆后的重逢',
        content: '男主在一场意外中失去记忆，忘记了曾经深爱的女主。五年后两人在异国他乡重逢，女主已经是知名设计师，而男主却成了她最大的竞争对手的未婚夫。',
        tags: ['现代', '虐恋', '重逢'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      InspirationItem(
        id: _uuid.v4(),
        content: '想写一个反派洗白的故事线：从小被当作工具培养的反派，在遇到一个天真善良的少年后，逐渐找回人性。但最终为了保护少年，不得不再次成为众人眼中的恶人。',
        tags: ['反派', '救赎', '悲剧'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      InspirationItem(
        id: _uuid.v4(),
        title: '时间循环的诅咒',
        content: '女主被困在同一天不断循环，每次循环都会发现新的线索。她逐渐意识到，打破循环的关键在于拯救一个她从未注意过的陌生人——而这个人，正是一百年前为她而死的恋人转世。',
        tags: ['奇幻', '时间循环', '前世今生'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      InspirationItem(
        id: _uuid.v4(),
        content: '灵感碎片：一个可以听到植物心声的少女，在城市的钢铁森林中感到窒息。直到她来到一座被遗忘的古老花园，听到了一株千年古树的低语。',
        tags: ['奇幻', '治愈', '少女'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 10)),
      ),
      InspirationItem(
        id: _uuid.v4(),
        title: '宫廷暗战',
        content: '新入宫的才人表面天真无害，实则步步为营。她利用每个人的弱点，在后宫的权力漩涡中悄然崛起。当所有人以为她是棋子时，才发现她早已是执棋之人。',
        tags: ['宫斗', '权谋', '女强'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 2, hours: 3)),
      ),
      InspirationItem(
        id: _uuid.v4(),
        content: '突发灵感：写一个美食与推理结合的故事。主角是一个天才厨师兼业余侦探，通过食物中的线索破解案件。每道菜背后都隐藏着一个秘密。',
        tags: ['现代', '推理', '美食'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      InspirationItem(
        id: _uuid.v4(),
        title: '末世求生日记',
        content: '病毒爆发后的第30天，幸存者们在一座废弃的商场里建立了临时避难所。资源日渐匮乏，人心开始动摇。女主必须在信任与生存之间做出选择。',
        tags: ['末世', '生存', '群像'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<PlotItem> getPlots() {
    final now = DateTime.now();
    return [
      PlotItem(
        id: _uuid.v4(),
        type: 'steps',
        steps: [
          '女主在宴会上被当众羞辱，说她配不上世家门第',
          '女主不卑不亢，以一首即兴诗惊艳全场',
          '曾经嘲笑她的贵女们面色铁青，纷纷沉默',
          '男主在暗处目睹一切，对女主刮目相看',
          '宴会后，之前羞辱女主的人反被家族长辈训斥',
        ],
        category: '打脸剧情',
        tags: ['爽文', '女主', '宴会'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      PlotItem(
        id: _uuid.v4(),
        type: 'steps',
        steps: [
          '贵妃设计陷害皇后，在御花园中安排假证据',
          '皇后身边的贴身宫女发现端倪，暗中调查',
          '关键时刻，一个不起眼的小太监提供了决定性的证词',
          '皇后在朝堂上当众揭露贵妃的阴谋',
          '皇帝震怒，贵妃被降为嫔位，党羽被清洗',
        ],
        category: '宫斗剧情',
        tags: ['权谋', '反转', '后宫'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      PlotItem(
        id: _uuid.v4(),
        type: 'free',
        freeContent: '男主假装不认识女主，实际上偷偷为她解决了所有麻烦。女主发现真相后感动落泪，两人在樱花树下和好。男主笨拙地表白："我不会说好听的话，但我这辈子只想对你好。"女主破涕为笑，踮起脚尖在他脸颊印下一吻。',
        category: '甜宠剧情',
        tags: ['甜蜜', '表白', '和好'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
      ),
      PlotItem(
        id: _uuid.v4(),
        type: 'steps',
        steps: [
          '对手在商业竞标中暗中使绊子，窃取了男主公司的方案',
          '男主发现后不动声色，将计就计修改了原方案中的关键数据',
          '竞标会上，对手自信满满地展示窃取的方案，却因数据错误当众出丑',
          '男主随后展示真正的方案，完美拿下项目',
          '事后查明对手的商业间谍身份，将其绳之以法',
        ],
        category: '打脸剧情',
        tags: ['商战', '智斗', '男主'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      PlotItem(
        id: _uuid.v4(),
        type: 'free',
        freeContent: '新入宫的小宫女意外救了受伤的年轻将军，将军承诺日后必报此恩。数年后，小宫女已成为太后身边的红人，而将军则手握兵权。朝堂风云变幻之际，两人在权力的棋盘上各怀心思，却又在深夜的密道中交换情报。他们之间，究竟是利益的交换，还是跨越身份的真心？',
        category: '宫斗剧情',
        tags: ['感情线', '权谋', '身份差'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      PlotItem(
        id: _uuid.v4(),
        type: 'steps',
        steps: [
          '女主雨天在公交站为男主撑伞，两人初次相遇',
          '发现彼此是新邻居，开始了日常的小互动',
          '男主偷偷在女主门口放早餐，女主假装不知道',
          '一次意外停电，两人在楼道里借着手机灯光聊了一整夜',
          '男主在女主生日时用满走廊的便利贴写满告白',
          '女主感动答应交往，两人甜蜜同行',
        ],
        category: '甜宠剧情',
        tags: ['现代', '邻居', '日常甜'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
