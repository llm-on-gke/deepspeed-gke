import mii
import huggingface_hub

huggingface_hub.login(token=os.environ.get('HUGGING_FACE_TOKEN', '')) ## Add your HF credentials

mii.serve("meta-llama/Llama-2-7b",tensor_parallel=2,replica_num=1)
