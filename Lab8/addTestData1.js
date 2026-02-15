// Для добавления тестовых данных выполнить представленный
// ниже код в интерфейсе mongosh

// Массивы для генерации данных
const boroughs = ["Bronx", "Brooklyn", "Manhattan", "Queens", "Staten Island"];
const cuisines = ["American", "Chinese", "Italian", "Japanese", "Mexican", "Indian", "Thai", "Russian", "French", "Pizza"];
const streets = ["Main St", "Oak Ave", "Pine Rd", "Maple Dr", "Elm Blvd", "Cedar Ln", "Washington St", "Church St"];
const names = ["Delicious", "Golden", "Royal", "Tasty", "Urban", "Grand", "Blue", "Red", "Green", "Sunset"];

// Функция генерации случайного целого числа
function randInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Функция генерации случайной даты за последние 5 лет
function randomDate() {
  const now = new Date();
  const fiveYears = 5 * 365 * 24 * 60 * 60 * 1000;
  const randomPast = now.getTime() - Math.random() * fiveYears;
  return new Date(randomPast);
}

// Функция генерации оценок (grades)
function generateGrades() {
  const count = randInt(1, 5);
  const grades = [];
  const possibleGrades = ["A", "B", "C"];
  for (let i = 0; i < count; i++) {
    grades.push({
      date: randomDate(),
      grade: possibleGrades[randInt(0, 2)],
      score: randInt(2, 15)
    });
  }
  return grades;
}

// Основной цикл вставки
const bulkOps = [];
const total = 1000;

for (let i = 0; i < total; i++) {
  const borough = boroughs[randInt(0, boroughs.length - 1)];
  const cuisine = cuisines[randInt(0, cuisines.length - 1)];
  const street = streets[randInt(0, streets.length - 1)];
  const namePrefix = names[randInt(0, names.length - 1)];
  const nameSuffix = cuisines[randInt(0, cuisines.length - 1)] + " Grill";

  bulkOps.push({
    insertOne: {
      document: {
        address: {
          building: String(randInt(1, 9999)),
          coord: [
            -74.0 + Math.random() * 0.5, // долгота Нью-Йорка
            40.5 + Math.random() * 0.5   // широта Нью-Йорка
          ],
          street: street,
          zipcode: randInt(10001, 11697)
        },
        borough: borough,
        cuisine: cuisine,
        grades: generateGrades(),
        name: namePrefix + " " + nameSuffix,
        restaurant_id: String(50000000 + i)
      }
    }
  });

  // Вставляем пакетами по 100 документов
  if (bulkOps.length === 100) {
    db.restaurants.bulkWrite(bulkOps);
    bulkOps.length = 0;
    print(`Inserted ${i + 1} / ${total}`);
  }
}

// Вставляем остаток
if (bulkOps.length > 0) {
  db.restaurants.bulkWrite(bulkOps);
}

print(`✅ Успешно вставлено ${total} тестовых ресторанов.`);