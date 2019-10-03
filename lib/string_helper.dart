String basHarfleriBuyult(String text) {
  return 
  text.split(' ').map(
    (s) => s = s[0].toUpperCase() + s.substring(1)
  ).join(' ');
}