MediGuide AI: An Explainable Healthcare Assistant

Abstract—The AI-assisted healthcare assistance systems are
mostly black box systems, providing predictions without any
reasoning behind, leading to the spread of misinformation, prescription
inaccuracies, and mistrust from the end-users. This research
proposes a modular approach that is based on MediGuide
AI, a system containing four modules such as disease prediction
based on symptoms, visual recognition of medicines, drug-drug
interaction (DDI) detection, and a retrieval-enhanced chatbot.
Feature-weighting based on severity scores helps establish a
mapping between symptoms and diseases using the Random
Forest model, whereas the OpenCV computer vision technique
recognizes visual features in the pills. Medical knowledge graph
validates the disease prediction output and serves as the base
for developing a DDI engine, and retrieval-augmented language
models (LLMs) provide clinically informed responses from the
chatbot. Accuracy of the system in symptom prediction and pill
recognition has reached 87% and 89%, respectively.
Index Terms—Explainable AI, Healthcare, Symptom Prediction,
Pill Identification, Drug Interaction, Knowledge Graph,
Random Forest, RAG, MobileNet
I. INTRODUCTION
AI adoption in the healthcare sector has led to the creation
of prediction models such as symptom checkers, drug safety
checkers, and patient interaction checkers. The current systems
used are black box systems that generate output but lack
explainability [1], [2]. The symptom checker models are not
consistently accurate in diagnosing illnesses [8], machine
learning-based recommendation models have problems with
non-generalizable data [2], and DDI checkers use tiny datasets
created manually [3]. Although the conversation models powered
by LLMs enhance interactions between patients and AI
agents, they generate inaccurate answers and are devoid of
medical information [4]. The MediGuide AI solution solves
this challenge by integrating the four capabilities into one AI
model: prediction, vision, interaction, and conversational AI.
