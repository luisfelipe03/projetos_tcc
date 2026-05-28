import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/project.dart';

class ProjectsService {
  ProjectsService._();
  static final ProjectsService instance = ProjectsService._();

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _projectsCollection =>
      _firestore.collection('projects');

  Stream<List<Project>> streamOpenProjects() {
    return _projectsCollection
        .where('status', isEqualTo: ProjectStatus.open.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Stream<List<Project>> streamMyProjects(String ownerId) {
    return _projectsCollection
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Future<String> createProject({
    required String ownerId,
    required String clientName,
    required String title,
    required String description,
    required List<String> skills,
    required String category,
    required double minBudget,
    required double maxBudget,
    required bool isHourly,
  }) async {
    final doc = await _projectsCollection.add({
      'ownerId': ownerId,
      'clientName': clientName,
      'title': title,
      'description': description,
      'skills': skills,
      'category': category,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'isHourly': isHourly,
      'proposalCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'status': ProjectStatus.open.name,
      'hasHeroImage': false,
    });
    return doc.id;
  }

  Project _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Project(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      skills: List<String>.from(data['skills'] as List? ?? const []),
      category: data['category'] as String? ?? '',
      minBudget: (data['minBudget'] as num?)?.toDouble() ?? 0,
      maxBudget: (data['maxBudget'] as num?)?.toDouble() ?? 0,
      isHourly: data['isHourly'] as bool? ?? false,
      proposalCount: (data['proposalCount'] as num?)?.toInt() ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ProjectStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ProjectStatus.open,
      ),
      clientName: data['clientName'] as String? ?? '',
      hasHeroImage: data['hasHeroImage'] as bool? ?? false,
    );
  }
}
