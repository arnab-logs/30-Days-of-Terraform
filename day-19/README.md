# Day 19 – Terraform Provisioners  
## 30 Days of AWS Terraform

Hello and welcome back to **30 Days of AWS Terraform** 
This is **Day 19** of the series.

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-44-day-19-aws-terraform-provisioners)

So far, we’ve covered a lot of ground. We didn’t just look at Terraform concepts in isolation — we built them up gradually through hands-on demos, mini projects, and real-world–style scenarios. Most recently, we worked on a mini project around **Image Processing using AWS Lambda**, which helped us move from simply *writing Terraform code* to actually *thinking in Terraform* — orchestrating multiple resources to solve a real problem.

Today, we move into a concept that naturally appears once infrastructure starts feeling real and usable: **Terraform Provisioners**.

---

## Why Provisioners Matter

The reason we’re learning this topic is simple.

Sometimes, creating infrastructure is not enough.

An EC2 instance might exist, but it’s not ready yet.  
A server might be running, but it still needs a bit of setup.

Maybe we want to:
- Run a command
- Install a package
- Copy a file
- Do a small preparation step automatically

Provisioners give us a **safe and structured way** to perform these actions during the lifecycle of a resource — without manually logging into servers every time.

By the end of this day, provisioners should feel like another practical tool in your Terraform toolbox — something you reach for when the situation calls for it.

## What Is a Provisioner?

Let’s start with a very simple question.

**What exactly is a provisioner in Terraform?**

At its core, a provisioner is something that performs a **task**.

That task could be:
- Running a command
- Executing a script
- Copying a file
- Performing a small operation at a specific moment

When Terraform creates or recreates a resource, a provisioner allows us to say:

> “Now that this thing exists, please do this extra step.”

Until now, most of our Terraform work focused on **creating infrastructure**:
- VPCs
- Subnets
- Security groups
- EC2 instances

Terraform is excellent at that. But sometimes, creation is only part of the story. Sometimes, we want to **prepare** the resource just enough so it’s usable.

That’s where provisioners come in.

---

## Important Mental Model

Provisioners:
- Do **work**
- Do **not define infrastructure**

They are **helpers**, not the foundation.

With that mental model, everything else starts to make sense.

---

## Types of Provisioners Covered Today

Terraform provides several provisioners. Today, we focus on three:

- `local-exec`
- `remote-exec`
- `file`

Each one solves a slightly different problem.

---

## Local-exec Provisioner

### What Is `local-exec`?

The `local-exec` provisioner runs commands **locally** — on the same machine where Terraform itself is running.

In our case, that’s usually:
- Our laptop
- Our personal development machine

When `local-exec` runs:
- Terraform does **not** connect to AWS
- Terraform does **not** log into the EC2 instance
- The command runs right on our own system

---

### Why Is This Useful?

`local-exec` gives us a structured way to attach a local helper command to the lifecycle of a resource.

Common use cases include:
- Printing information
- Logging values
- Triggering a local script
- Simple notifications

---

### Example Local-exec Provisioner

```hcl
provisioner "local-exec" {
  command = "echo Instance ${self.id} created with IP ${self.public_ip}"
}
````

Even though the command runs locally, Terraform already knows about the resource and can interpolate values like:

* Instance ID
* Public IP

---

### Re-running Provisioners

Provisioners do not count as infrastructure changes.

To re-run them, we can mark a resource as tainted:

```bash
terraform taint aws_instance.example
```

Then apply again:

```bash
terraform apply
```

Terraform will:

* Destroy the resource
* Recreate it
* Re-run the provisioners

---

## Remote-exec Provisioner

### What Is `remote-exec`?

While `local-exec` runs commands on our machine, `remote-exec` runs commands **on the remote resource itself**.

In our case:

* The remote machine is the EC2 instance
* Terraform connects over SSH
* Commands are executed on the server

This is a big shift, so it’s worth pausing here.

---

### Why the Connection Block Matters

For `remote-exec` to work, Terraform must know:

* Which user to log in as
* Which private key to use
* Which host to connect to

That’s why the `connection` block is required.

Without it, remote execution is impossible.

---

### Example Remote-exec Provisioner

```hcl
provisioner "remote-exec" {
  inline = [
    "sudo apt update",
    "echo 'Hello from remote-exec' > /tmp/remote_exec.txt"
  ]
}
```

These commands run exactly as if we had SSH’d into the instance and typed them ourselves.

---

### Verifying Remote Execution

After apply:

* SSH into the instance
* Check the `/tmp` directory
* Open the file

The presence of the file confirms that `remote-exec` truly ran on the remote machine.

---

## File Provisioner

### What Is the File Provisioner?

The `file` provisioner is used to **copy files** from the local machine to the remote resource.

This is useful when we want:

* Scripts
* Configuration files
* Assets
* Setup files

Available immediately after the instance is created.

---

### Example File Provisioner

```hcl
provisioner "file" {
  source      = "${path.module}/scripts/welcome.sh"
  destination = "/tmp/welcome.sh"
}
```

---

### How It Works

* `source` points to a local file
* `destination` is the path on the EC2 instance
* File transfer happens over SSH
* The `connection` block is required

Once copied, the file can be:

* Executed
* Read
* Used by `remote-exec`

---

## Putting It All Together

By the end of Day 19, we learned that:

* Provisioners run tasks, not infrastructure
* `local-exec` runs commands on our machine
* `remote-exec` runs commands on the server
* `file` copies files to the server
* Provisioners run during resource creation
* Tainting forces re-execution

Provisioners are powerful, but they should be used **thoughtfully** — as helpers, not replacements for proper configuration management.

---

## Closing Thoughts

Today was a shorter, lighter session compared to some of the heavier days before it — and that’s intentional. Provisioners are easier to grasp when we see them as small, practical helpers rather than complex abstractions.

If you want a clear walkthrough and troubleshooting guidance, there’s an excellent video by **Piyush Sachdeva** that explains provisioners step by step and is easy to follow along with.

With that, we’ve completed **Day 19** of the challenge.

```
```
