
# 30 Days of AWS Terraform – Day 11: Terraform Functions (Part 1)

Hello and welcome back to our **30 Days of AWS Terraform journey!**  

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-36-day-11-aws-terraform-functions-part-1)

Last session, we dived into some fascinating pieces of Terraform, including **conditional expressions, splat expressions, and dynamic blocks**. Each of these little gems helped us see how Terraform makes infrastructure descriptions more flexible and expressive.

Today, we’re turning our attention to **Terraform Functions – Part 1**.  

---

## Introduction to Terraform Functions

Now, if the word “function” makes you imagine complicated programming, don’t worry—that’s not what we’re doing here. Terraform isn’t a programming language. It’s a **configuration language**, which simply means we describe what we want our infrastructure to look like, rather than writing a program to compute it.  

To make that description a bit smarter and more reusable, Terraform provides **built-in helpers called functions**.

Because there are so many functions, we’ll explore them in **two parts**. In Part 1, we’ll cover:  

- What a function really is  
- Why Terraform only gives us inbuilt functions  
- How these helpers make our variables and values cleaner and easier to manage  

---

## Understanding Functions and Terraform’s Inbuilt Functions

### What is a Function, Really?

Before we dive into Terraform-specific functions, let’s understand a function in the simplest way:  

A **function** is something that **makes our life easier**. It allows us to **reuse instructions** instead of rewriting the same steps over and over.

**Example:** Adding two numbers in a programming language:

```python
a = 2
b = 3
c = a + b
print(c)
```

Simple, right? But what if we had to do this 10 different times with different numbers? Copy-pasting isn’t efficient.

Here’s where a function helps: wrap the logic once, then call it whenever needed, passing in new values. The code stays clean, and work becomes faster and more organized.

Terraform is Not a Programming Language
Terraform is a configuration language (HCL – HashiCorp Configuration Language), not a full programming language. This means:

Terraform does not have classes, objects, or OOP features

We cannot create our own custom functions

Instead, Terraform provides inbuilt functions that can be used anywhere in configurations

These functions cover:

### String manipulation

### Numeric operations

### Collections (lists and maps)

### Type conversion

### Date and time handling

### Validation and lookup

Even though Terraform can’t do everything a programming language can, these functions allow us to write clean, reusable, and dynamic infrastructure code.

Categories of Terraform Functions
Here’s a high-level view of the main categories:

### String functions – manipulate and transform text

### Numeric functions – calculate max, min, absolute, etc.

### Collection functions – work with lists and maps

### Type conversion functions – convert between lists, sets, numbers, and strings

### Date and time functions – work with timestamps and formatted dates

### Validation and lookup functions – check or select values dynamically

Think of these functions as little helpers that make Terraform more expressive and less repetitive—like tools in your toolbox.

### Terraform String Functions
String functions let us manipulate text, making it easier to format, clean, or transform strings before using them in our infrastructure.

Upper and Lower Functions

```hcl
upper("hello terraform")  # "HELLO TERRAFORM"
lower("HELLO TERRAFORM")  # "hello terraform"
```

### Trim Function

```hcl
trim("  hello  ", " ")  # "hello"
```
Removes unwanted characters from the start and end of a string.

### Replace Function

```hcl
replace("hello terraform", " ", "-")  # "hello-terraform"
```

Replaces occurrences of a character or substring with another.

### Substring Function

```hcl
substr("terraform", 0, 4)  # "terr"
```

Extracts a portion of a string from a starting index up to a given length. Useful for formatting names.

### Numeric and Collection Functions

Numeric Functions
max(): returns the largest number

min(): returns the smallest number

abs(): returns the absolute value

### Collection Functions
length(): counts elements in a list

concat(): combines multiple lists

merge(): combines multiple maps

These are essential when working with tags, security groups, or lists of values, allowing dynamic and clean configurations.

### Type Conversion and Date/Time Functions
### Type Conversion
toset(): converts a list into a set

tonumber(): converts a numeric string into a number

### Date/Time Functions
timestamp(): returns current timestamp

formatdate(): formats a timestamp in a custom way

These functions ensure Terraform handles types and time-based data correctly.

### Practical AWS Examples
Lowercase and Replace for Project Names

```hcl
variable "project_name" {
  default = "Mission is TERRAFORM"
}

locals {
  formatted_name = replace(lower(var.project_name), " ", "-")
}
```
Output: "mission-is-terraform"
Ensures safe, clean names for resources like S3 buckets.

Merge Function for Tags

```hcl
tags = merge(var.default_tags, var.environment_tags)
```

Combines default and environment-specific tags without duplication.

Substring, Lower, Replace for S3 Buckets

Enforces rules like lowercase, max 64 characters, no spaces:

```hcl
bucket_name = replace(substr(lower(var.bucket_name), 0, 64), " ", "-")
```

Split and For Expression for Ports

Convert a string of ports into a list and iterate to create security rules.

Lookup Function for Environment-Specific Values

```hcl
variable "instance_sizes" {
  default = {
    dev     = "t2.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }
}

locals {
  instance_size = lookup(var.instance_sizes, var.environment, "t2.micro")
}
```
Terraform dynamically selects the instance size based on the environment, making configurations flexible and safe.


Tomorrow, we’ll continue with Part 2, diving deeper into more functions and practical examples. Take your time to experiment with these examples and make them your own.
