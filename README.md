# Kiwi - Redmine Plugin

This project also contains my notes about Redmine Plugin Development but in Turkish ;)

- [Redmine Eklentisi Geliştirmek](./Redmine-Eklenti-Gelistirmek.md)
- [Redmine Notlarım](./Redmine-Notlarim.md)

To retrieve Kiwi Test Cases from Kiwi server there will be needed to define all the settings in plugin settings page.

![image](https://github.com/cemtopkaya/ulak_test/assets/261946/24f7f0d4-9861-45ba-96eb-e8579e6bc437)

This plugin creates a relation between Kiwi tests and issues. To make this relation both creating or editing issue you can add tests to the issue.

![image](https://github.com/cemtopkaya/ulak_test/assets/261946/9079ba16-fe2b-4ae0-9be1-7c796bef8e0e)

When the issue has tests and is associated with any code change this plugin creates Test Results tab at the end of tabs below of the page.
This tab contains revisions and tags related with code revisions. When any tag contains description like below, all artifacts extracts by plugin in tag description and looks for this artifact names in kiwi test run's tags.

```yaml
distros:
- package: cnrpcfoms-vnf
  version: 1.2.0-1-ba02a366
  packageType: debian
  kernel: 4.4.0-210-generic
  distribution: Ubuntu 16.04.7 LTS
  urgency: low
  artifacts:
  - cnrpcfoms-vnf_1.2.0-1-ba02a366_amd64.deb
- package: cnrpcfoms-cnf
  version: 1.2.0-1-ba02a366
  packageType: debian
  kernel: 4.4.0-210-generic
  distribution: Ubuntu 16.04.7 LTS
  urgency: low
  artifacts:
  - cnrpcfoms-cnf_1.2.0-1-ba02a366_amd64.deb
  - registry.ulakhaberlesme.com.tr/cinar/pcf/oms:1.2.0-1-ba02a366
```

![image](https://github.com/cemtopkaya/ulak_test/assets/261946/f6cf8ef5-4277-47b7-a154-ef73689ca221)

![image](https://github.com/cemtopkaya/ulak_test/assets/261946/c69b5381-2bbe-4849-bf79-6167022db950)

![image](https://github.com/cemtopkaya/ulak_test/assets/261946/7addb947-4824-4559-be48-b009902303ca)


## v2 Changed From Test Cases To Test Plans
![image](https://github.com/cemtopkaya/ulak_test/assets/261946/632f8b75-0722-4ec2-bf71-edb5a7b2cb94)

![image](https://github.com/cemtopkaya/ulak_test/assets/261946/55ffa1b6-09c9-40a7-aad0-4a22c901bb97)
