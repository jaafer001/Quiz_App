class Validators {
  static String? validateQuestion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a question";
    }
    if (value.trim().length < 3) {
      return "Question is too short (min 3 characters)";
    }
    return null;
  }

  static String? validateAnswer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter an answer";
    }
    if (value.trim().isEmpty) {
      return "Answer cannot be empty";
    }
    return null;
  }
}
