class ConversationModel {
  final String id;
  final String name;
  final List<String> participantIds;
  
  const ConversationModel({
    required this.id,
    required this.name,
    required this.participantIds,
  });
}
