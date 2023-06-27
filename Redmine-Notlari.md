
Rails'in varsayılan davranışları hakkında başlıklar ve açıklamalar:

1. Tablo Adları:
   - Başlık: Tekil Tablo Adları
   - Açıklama: Rails, ilişkili modellerin tablo adlarını oluştururken, genellikle tekil isimlere çoğul ek ekler. Örneğin, `Issue` modeli için ilişkili tablo adı `issues` olur.

2. Model Adları:
   - Başlık: Tekil Model Adları
   - Açıklama: Rails, model isimlerini tekil olarak kabul eder. Örneğin, `Issue` modeli için tekil model adı `Issue` olur.

3. İlişkili Tablo Adları:
   - Başlık: Çoğul İlişkili Tablo Adları
   - Açıklama: Rails, ilişkili tabloların çoğunlukla birçok örneğini içerdiği durumlarda çoğul tablo adlarını kullanır. Örneğin, `Issue` modeli için ilişkili tablo adı `issues` olur.

4. İlişkili Model Adları:
   - Başlık: Çoğul İlişkili Model Adları
   - Açıklama: Rails, ilişkili modellerin çoğunlukla birçok örneğini içeren ilişkili tablolar için çoğul model adlarını kullanır. Örneğin, `:issues` ifadesi, ilişkili tabloyu doğru şekilde temsil eder.

Bu davranışlar, Rails'in birçok projede kullanılan yaygın kabulleri ve sözleşmeleridir. Bunlar, Rails'in kendi varsayılanlarını takip eden ve geliştiriciler arasında tutarlılık sağlayan bir yapı sunmasını sağlar. Ancak, ihtiyaçlarınıza göre bu davranışları değiştirebilir ve özelleştirebilirsiniz.
