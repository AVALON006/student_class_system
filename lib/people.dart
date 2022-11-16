class People {
  String no;
  String name;
  String sex;
  int age;
  int role;
  People(this.no, this.name, this.sex, this.age, this.role);
}

class Teacher extends People {
  Teacher(String no, String name, String sex, int age)
      : super(no, name, sex, age, 2);
}

class Student extends People {
  Student(String no, String name, String sex, int age)
      : super(no, name, sex, age, 1);
}
