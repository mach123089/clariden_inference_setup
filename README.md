# Apartus-Tool-Gym Inference Nodes Setup

## Description
This repository contains files to make it easier to set up inference nodes for Apartus-Tool-Gym.

It uses a fork from the swiss-ai/torrent repo (https://github.com/swiss-ai/torrent/tree/main)

---

## Setup Steps
1. Run the setup script:
```bash
./setup.sh
```
2. Follow the command printed at the end of the setup, for example:

```bash
srun -A infra01 -t 2:00:00 --export=HF_HOME=/iopsstor/scratch/cscs/[ID]/huggingface --environment=./deployment.toml --pty bash
```

## Testing Deployment

1. Once connected to the node, submit a single-node job:

```bash
python serving/single-node/submit_job.py --workers 1 --model-path Qwen/Qwen3-Next-80B-A3B-Thinking --tp-size 4
```

2. Wait a bit, then monitor the worker error log:

```bash
tail -f logs/[JOB_ID]/worker0_node_nid[NODE_ID].err
```

The server should be ready when it shows:
```pgsql
[2025-11-30 13:38:14] The server is fired up and ready to roll!
```

3. Test inference with the following curl command (replace [NODE_ID] with the correct node ID from the log output `log.out`):

```bash
curl http://nid[NODE_ID]:5000/v1/chat/completions \
-H "Content-Type: application/json" \
-d '{
  "model": "Qwen/Qwen3-Next-80B-A3B-Thinking",
  "messages": [
    {"role": "user", "content": "Hello! Are you working?"}
  ],
  "max_tokens": 50
}'
```

Expected output should be a JSON response from the model:

```json
{"id":"c70ca8929be34c1f8ebff3592cd9e478","object":"chat.completion","created":1764506908,"model":"Qwen/Qwen3-Next-80B-A3B-Thinking","choices":[{"index":0,"message":{"role":"assistant","content":"Okay, the user said, Hello! Are you working? Let me think about how to respond.\n\nFirst, I need to confirm that I'm an AI, so I should mention that I'm always here to help. But I should keep it friendly","reasoning_content":null,"tool_calls":null},"logprobs":null,"finish_reason":"length","matched_stop":null}],"usage":{"prompt_tokens":16,"total_tokens":66,"completion_tokens":50,"prompt_tokens_details":null,"reasoning_tokens":0},"metadata":{"weight_version":"default"}}

```

4. Cancel the job once tested:
```bash
scancel [job_id]
```

You can copy the exact scancel command from `log.out`


