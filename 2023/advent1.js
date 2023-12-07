(function() {
  let text = document.body.textContent.split(/\s+/);
  let sum = 0;

  const digits = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9'
  ];

  const words = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine'
  ];

  text.forEach(function(str) {
      let nums = str.match(new RegExp('([' + digits.join("") + ']|' + words.join('|') + ')', 'g'));
      if (!nums) return;

      let first = nums[0];

      for (let i = str.length - 1; i >= 0; i--) {
        let endSub = str.slice(i);
        let endNums = endSub.match(new RegExp('([' + digits.join("") + ']|' + words.join('|') + ')', 'g'));

        if (endNums) {
          last = endNums[endNums.length - 1];
          break;
        }
      }

      console.log(str, first, last);
      
      first = (words.indexOf(first) > -1 ? words.indexOf(first) : digits.indexOf(first)).toString();
      last = (words.indexOf(last) > -1 ? words.indexOf(last) : digits.indexOf(last)).toString();
      let num = parseInt(first + last);
      console.log(num);
      sum += num;
  });

  console.log(sum);
})();