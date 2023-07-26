INSERT INTO food(food_id, name, food_type) 
        VALUES ('f7337122-b018-48ad-b420-6202dc3cb4ff', 'Geflügel - Cevapcici, Ajvar, Djuvec Reis', 'UNKNOWN'),
        ('73cf367b-a536-4b49-ad0c-cb984caa9a08', 'zu jedem Gericht reichen wir ein Dessert oder Salat', 'UNKNOWN'),
        ('25cb8c50-75a4-48a2-b4cf-8ab2566d8bec', '2 Dampfnudeln mit Vanillesoße', 'VEGETARIAN'),
        ('0a850476-eda4-4fd8-9f93-579eb85b8c25', 'Mediterraner Gemüsegulasch mit Räuchertofu, dazu Sommerweizen', 'VEGAN'),
        ('1b5633c2-05c5-4444-90e5-2e475bae6463', 'Cordon bleu vom Schwein mit Bratensoße', 'PORK'),
        ('836b17fb-cb16-425d-8d3c-c274a9cdbd0c', 'Salatbuffet mit frischer Rohkost, Blattsalate und hausgemachten Dressings, Preis je 100 g', 'VEGAN'),
        ('2c662143-eb84-4142-aa98-bd7bdf84c498', 'Insalata piccola - kleiner Blattsalat mit Thunfisch und Paprika', 'UNKNOWN');

INSERT INTO meal(food_id)
        VALUES  ('f7337122-b018-48ad-b420-6202dc3cb4ff'),
                ('25cb8c50-75a4-48a2-b4cf-8ab2566d8bec'),
                ('0a850476-eda4-4fd8-9f93-579eb85b8c25'),
                ('1b5633c2-05c5-4444-90e5-2e475bae6463');