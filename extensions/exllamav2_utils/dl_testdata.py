from datasets import load_dataset

# Load the dataset
dataset = load_dataset("stas/openwebtext-10k")

# Save the text to a file
with open("corpus.txt", "w", encoding="utf-8") as f:
    for item in dataset["train"]:
        f.write(item["text"] + "\n")
