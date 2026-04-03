import '../models/inspiration_item.dart';
import '../models/material_item.dart';
import '../models/plot_item.dart';
import '../models/vocabulary_item.dart';

class SampleData {
  static List<MaterialItem> getMaterials() {
    final now = DateTime.now();
    return [
      MaterialItem(
        id: 'sample-material-1',
        content: '她抬眼看向窗外，雨丝像被夜色揉碎的银线，斜斜落在玻璃上。',
        category: '环境描写',
        tags: const ['雨夜', '氛围'],
        source: '预设',
        isFavorite: true,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      MaterialItem(
        id: 'sample-material-2',
        content: '“我不是来解释的，”他说，“我是来把你带回去的。”',
        category: '对话',
        tags: const ['男女主', '冲突'],
        source: '预设',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ];
  }

  static List<VocabularyItem> getVocabulary() {
    final now = DateTime.now();
    return [
      VocabularyItem(
        id: 'sample-vocabulary-1',
        content: '呼吸微滞',
        category: '神态',
        tags: const ['情绪'],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      VocabularyItem(
        id: 'sample-vocabulary-2',
        content: '光影浮动',
        category: '环境',
        tags: const ['氛围'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  static List<InspirationItem> getInspirations() {
    final now = DateTime.now();
    return [
      InspirationItem(
        id: 'sample-inspiration-1',
        title: '真假未婚妻',
        content: '订婚宴当天真正的新娘消失，女主被迫顶上，却发现男主早就认出了她。',
        tags: const ['都市', '反转'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      InspirationItem(
        id: 'sample-inspiration-2',
        content: '写一个“旧城改造”背景下的重逢故事，人物关系可以很克制。',
        tags: const ['现实向'],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<PlotItem> getPlots() {
    final now = DateTime.now();
    return [
      PlotItem(
        id: 'sample-plot-1',
        type: 'steps',
        steps: const [
          '女主接到前任婚礼请柬',
          '在婚礼现场意外遇见多年未见的男主',
          '男主替她挡下尴尬局面',
        ],
        category: '甜宠剧情',
        tags: const ['重逢', '婚礼'],
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
