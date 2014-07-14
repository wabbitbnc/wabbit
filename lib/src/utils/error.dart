part of wabbit;

printError(String section, dynamic err, [List<String> extraInfo]) {
  print("------- Error in $section -------");
  print("Error: $err");
  if (extraInfo != null)
    print("Extra information - \n\t${extraInfo.join("\n\t")}");
  print("------- End error in $section -------");
}
